class Symphony::InvoicesController < ApplicationController
  include Adapter
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company, except: [:get_xero_item_code_detail]
  before_action :set_workflow, except: [:get_xero_item_code_detail]
  before_action :set_workflows_navigation, only: [:new, :create, :edit]
  before_action :set_documents, except: [:get_xero_item_code_detail]
  before_action :set_invoice, only: [:edit, :update, :show, :destroy]
  before_action :set_last_workflow_action, only: :show
  before_action :get_xero_details

  after_action :verify_authorized, except: [:create, :index, :get_xero_item_code_detail, :next_invoice, :prev_invoice]
  after_action :verify_policy_scoped, only: :index

  def new
    @invoice = Invoice.new
    authorize @invoice

    @invoice.build_line_item
    @xero = Xero.new(@company)
  end

  def create
    @invoice = Invoice.new(invoice_params)
    authorize @invoice
    @invoice.workflow_id = @workflow.id
    @invoice.user_id = current_user.id
    @invoice.company_id = current_user.company_id
    if @invoice.xero_contact_id.present?
      @invoice.xero_contact_name = @xero.get_contact(@invoice.xero_contact_id).name
    else
      #if invoice.xero_contact_id is not present, then create a contact in Xero
      contact_id = @xero.create_contact(name: @invoice.xero_contact_name)
      @invoice.xero_contact_id = contact_id
    end

    if @invoice.save
      if @workflow.batch
        #set completed task
        update_workflow_action_completed(params[:workflow_action_id])
        #go to the next invoice
        redirect_to_next_action(@workflow, params[:workflow_action_id])
      else
        redirect_to symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @invoice.id), notice: "Invoice created successfully."
      end
    else
      render 'new'
    end
  end

  def edit
    authorize @invoice
    if @invoice.xero_total_mismatch?
      @xero = Xero.new(@company)
      @xero_invoice = @xero.get_invoice(@invoice.xero_invoice_id)
      #get the total of the sent invoice in Xero
      @invoice.add_line_item_for_rounding(@xero_invoice.total)
      @invoice.save
    end
  end

  def update
    authorize @invoice
    @xero = Xero.new(@company)
    if params[:invoice][:xero_contact_name].blank?
      @invoice.xero_contact_name = @xero.get_contact(params[:invoice][:xero_contact_id]).name
    else
      contact_id = @xero.create_contact(name: params[:invoice][:xero_contact_name])
      @invoice.xero_contact_id = contact_id
    end
    @invoice.save
    if @invoice.update(invoice_params)
      #If associate wants to update invoice before sending to xero, symphony finds the params update_field and then redirect to the same invoice EDIT page
      if params[:update_field] == "success"
        redirect_to edit_symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @workflow.invoice.id, workflow_action_id: params[:workflow_action_id]), notice: 'Symphony invoice successfully updated'
      #when invoice updates with the rounding line item, update the invoice in Xero as well
      elsif @invoice.xero_total_mismatch?
        @xero_invoice = @xero.get_invoice(@invoice.xero_invoice_id)
        @update_xero_invoice = @xero.updating_invoice_payable(@xero_invoice, @invoice.line_items)

        if @workflow.batch.present?
          #In batch, check whether there is a next workflow
          workflow_action = @workflow.workflow_actions.find(params[:workflow_action_id])
          next_wf = @workflow.batch.next_workflow_with_action_incomplete(@workflow, workflow_action)
          if @invoice.errors.empty?
            if next_wf.present?
              #check is the workflow have workflow action and have an invoice? if yes go to next invoice page, if not go to batch page
              if next_wf.get_workflow_action(workflow_action.task_id).present? && next_wf.invoice.present?
                redirect_to edit_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, id: next_wf.invoice.id, workflow_action_id: next_wf.get_workflow_action(workflow_action.task_id).id), notice: 'Xero invoice updated successfully.'
              else
                redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id, notice: 'Xero invoice updated successfully.')
              end
            else
              redirect_to symphony_batches_index_path, notice: 'Xero invoice updated.'
            end
          else
            redirect_to symphony_batches_index_path, alert: 'Xero invoice not updated. Please try again.'
          end
        else
          redirect_to edit_symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @invoice.id, workflow_action_id: params[:workflow_action_id])
        end
      elsif @invoice.workflow.batch.present? && params[:workflow_action_id].present?
        #set completed task
        if @invoice.approved?
          update_workflow_action_completed(params[:workflow_action_id])
        end
        #go to the next invoice
        redirect_to_next_action(@workflow, params[:workflow_action_id])
      else
        flash[:alert] = @invoice.errors.full_messages.join(', ')
        redirect_to edit_symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @invoice.id, workflow_action_id: params[:workflow_action_id])
      end
    else
      flash[:alert] = @invoice.errors.full_messages.join(', ')
      redirect_to edit_symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @invoice.id, workflow_action_id: params[:workflow_action_id])
    end
  end

  def show
    authorize @invoice
    @total = @invoice.total_amount
  end

  def destroy
    authorize @invoice

    #if invoice is sent to xero already, then set xero invoice status to deleted or voided, depending on the current status
    if @invoice.xero_invoice_id.present?
      @delete_invoice = @xero.get_invoice(@invoice.xero_invoice_id)
      if (@delete_invoice.status == "SUBMITTED")
        @delete_invoice.status = "DELETED"
      #if invoice is "AUTHORISED", it could only be voided
      else
        @delete_invoice.status = "VOIDED"
      end
      @delete_invoice.save
    end
    @invoice.destroy!
    @batch = @workflow.batch
    if @batch.present?
      Document.where(workflow_id: @workflow.id).destroy_all
      @workflow.destroy!
    end
    respond_to do |format|
      flash[:notice] = "Invoice has been deleted successfully."
      if @batch.present?
        format.html { redirect_to symphony_batch_path(batch_template_name: @batch.template.slug, id: @batch.id) }
      else
        format.html { redirect_to symphony_workflow_path(@workflow.template.slug, @workflow.id) }
      end
    end
  end

  def get_xero_item_code_detail
    @item_code_list = @xero.get_item_attributes(params[:item_code])
    respond_to do |format|
      if @item_code_list.present?
        format.json { render json: @item_code_list[0], status: :ok }
      else
        format.json { render json: @item_code_list[0].errors, status: :unprocessable_entity }
      end
    end
  end

  def reject
    invoice_id = params[:id]
    if invoice_id.blank?
      @invoice = Invoice.new
      @invoice.workflow_id = @workflow.id
      @invoice.user_id = current_user.id
      @invoice.company_id = current_user.company_id
      @invoice.invoice_type = params[:invoice_type]
    else
      @invoice = Invoice.find(invoice_id)
    end
    authorize @invoice
    if @invoice.save(validate: false)
      if @invoice.update_attribute(:status, "rejected")
        flash[:notice] = "Invoice has been rejected."
        if @invoice.workflow.batch.present?
          #set completed task
          update_workflow_action_completed(params[:workflow_action_id])
          #go to the next invoice
          redirect_to_next_action(@workflow, params[:workflow_action_id])
        else
          redirect_to symphony_workflow_path(@nvoice.workflow.template.slug, @nvoice.workflow.id)
        end
      else
        if invoice_id.present?
          render :edit
        else
          render :new
        end
      end
    else
      if invoice_id.present?
        render :edit
      else
        render :new
      end
    end
  end

  def next_invoice
    next_wf = @workflow.batch.next_workflow(@workflow)
    next_wf_action = next_wf.workflow_actions.where(completed: false).first
    if next_wf_action.blank?
      next_wf_action = next_wf.workflow_actions.where(completed: true).last
    end
    if next_wf.present?
      render_action_invoice(next_wf, next_wf_action)
    else
      redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id)
    end
  end

  def prev_invoice
    prev_wf = @workflow.batch.previous_workflow(@workflow)
    if prev_wf.present?
      # check if previous workflow have invoice and is that invoice xero total mismatch? if yes go to previous page if not go to first invoice
      if prev_wf.invoice.present? and prev_wf.invoice.xero_total_mismatch?
        render_action_invoice(prev_wf, prev_wf.workflow_actions.where(completed: true).last)
      else
        render_action_invoice(prev_wf, prev_wf.workflow_actions.where(completed: false).first)
      end
    else
      redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id)
    end
  end

  private
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def set_workflow
    @workflow = @company.workflows.find(params[:workflow_id])
  end

  def set_workflows_navigation
    @workflow_action = @workflow.workflow_actions.find(params[:workflow_action_id])
    @workflows = @workflow.batch.workflows.includes(workflow_actions: :task).where(workflow_actions: {tasks: {id: @workflow_action.task_id}}).order(created_at: :asc)

    @total_task = @workflows.count
    @total_completed_task = @workflow.batch.workflows.includes(workflow_actions: :task).where(workflow_actions: {tasks: {id: @workflow_action.task_id}, completed: true}).count

    # check using max, show maximum value. use square baracket [] for value
    @remaining_invoices = [@total_task - @total_completed_task - 1, 0].max

    @current_position = @workflows.pluck('id').index(@workflow.id)+1
  end

  def set_company
    @company = current_user.company
  end

  def set_documents
    @documents = @workflow.documents.where(workflow_id: @workflow.id).order(created_at: :desc)
    unless @documents.empty?
      @document = @documents.where(id: params[:document_id]).exists? ? @documents.find(params[:document_id]) : @documents.last
      @previous_document = @documents.where('id < ?', @document.id).first
      @next_document = @documents.where('id > ?', @document.id).last
    end
  end

  def set_last_workflow_action  
    @last_workflow_action = @workflow.workflow_actions.includes(:task).where(completed: false).order("tasks.position ASC").first&.id
  end

  def get_xero_details
    @xero = Xero.new(current_user.company)
    @clients                = @xero.get_contacts
    # Combine account codes and account names as a string
    @full_account_code      = @xero.get_accounts.map{|account| (account.code + ' - ' + account.name) if account.code.present?} #would not display account if account.code is missing
    @full_tax_code          = @xero.get_tax_rates.map{|tax| tax.name + ' (' + tax.display_tax_rate.to_s + '%) - ' + tax.tax_type} # Combine tax codes and tax names as a string
    @currencies             = @xero.get_currencies
    @tracking_name          = @xero.get_tracking_options
    @tracking_categories_1  = @tracking_name[0]&.options&.map{|option| option}
    @tracking_categories_2  = @tracking_name[1]&.options&.map{|option| option}
    @items                  = @xero.get_items.map{|item| (item.code + ': ' + (item.description || '-')) if item.code.present?}
  end

  def invoice_params
    params.require(:invoice).permit(:invoice_date, :due_date, :workflow_id, :workflow_action_id, :line_amount_type, :invoice_type, :xero_invoice_id, :invoice_reference, :xero_contact_id, :xero_contact_name, :currency, :status, :total, :user_id, line_items_attributes: [:item, :description, :quantity, :price, :account, :tax, :tracking_option_1, :tracking_option_2, :_destroy])
  end

  def render_action_invoice(workflow, workflow_action)
    if workflow.invoice.blank?
      invoice_type = params[:invoice_type].present? ? params[:invoice_type] : @workflow.invoice&.invoice_type
      redirect_to new_symphony_invoice_path(workflow_name: workflow.template.slug, workflow_id: workflow.id, invoice_type: invoice_type, workflow_action_id: workflow_action)
    elsif workflow.invoice.present?
      redirect_to edit_symphony_invoice_path(workflow_name: workflow.template.slug, workflow_id: workflow.id, id: workflow.invoice.id, workflow_action_id: workflow_action)
    end
  end

  def redirect_to_next_action(workflow, workflow_action_id)
    workflow_action = WorkflowAction.find(workflow_action_id)
    incomplete_workflows = workflow.batch.workflows.includes(workflow_actions: :task).where(workflow_actions: {tasks: {id: workflow_action.task_id}, completed: false}).order(created_at: :asc)

    if params[:action] == "update"
      incomplete_workflows = incomplete_workflows.includes(:invoice).where.not(invoices: {id: nil})
    end
    
    if incomplete_workflows.count > 0
      next_wf = incomplete_workflows.where('workflows.created_at > ?', workflow.created_at).first
      if next_wf.blank? 
        next_wf = incomplete_workflows.where('workflows.created_at < ?', workflow.created_at).first
      end

      if next_wf.present?
        next_wf_action = next_wf.workflow_actions.where(completed: false).first
        if params[:action] == "update"
          redirect_to edit_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, id: next_wf.invoice.id, workflow_action_id: next_wf_action.id)
        else
          invoice_type = params[:invoice_type].present? ? params[:invoice_type] : next_wf.invoice&.invoice_type
          redirect_to new_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, invoice_type: invoice_type, workflow_action_id: next_wf_action.id)
        end
      else
        redirect_to symphony_batch_path(batch_template_name: workflow.batch.template.slug, id: workflow.batch.id, notice: "#{workflow_action.task.task_type.humanize}task has been saved")
      end      
    else
      redirect_to symphony_batch_path(batch_template_name: workflow.batch.template.slug, id: workflow.batch.id, notice: "#{workflow_action.task.task_type.humanize}task has been completed")
    end    
  end

  def update_workflow_action_completed(workflow_action_id)
    workflow_action = WorkflowAction.find(workflow_action_id)
    workflow_action.update_attributes(completed: true, completed_user_id: current_user.id)
  end
end
