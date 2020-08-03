class Symphony::InvoicesController < ApplicationController
  include Adapter
  include Symphony::InvoicesHelper
  require "mini_magick"

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_workflow
  before_action :set_workflows_navigation, only: [:new, :create, :edit]
  before_action :set_documents
  before_action :set_invoice, only: [:edit, :update, :show, :destroy]
  before_action :set_show_invoice_navigation, only: [:show, :next_show_invoice, :prev_show_invoice]
  before_action :set_last_workflow_action, only: :show
  before_action :get_xero_details

  after_action :verify_authorized, only: [:new, :create, :edit, :update, :show, :destroy, :reject]
  after_action :verify_policy_scoped, only: :index

  def new
    @invoice = Invoice.new
    authorize @invoice
    @invoice.build_line_item
  end

  def create
    @invoice = Invoice.new(invoice_params)
    authorize @invoice
    @invoice.workflow_id = @workflow.id
    @invoice.user_id = current_user.id
    @invoice.company_id = @company.id
    # Since only payable is used, we can manually set payable to invoice type
    @invoice.invoice_type = "payable"
    update_xero_contacts(params[:invoice][:xero_contact_name], params[:invoice][:xero_contact_id], @invoice, @clients)

    if @invoice.save
      if @workflow.batch
        #set completed task
        update_workflow_action_completed(params[:workflow_action_id], current_user)
        #go to the next invoice
        redirect_to_next_action(@workflow, params[:workflow_action_id])
      else
        redirect_to symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.friendly_id, id: @invoice.id), notice: "Invoice created successfully."
      end
    else
      render 'new'
    end
  end

  def edit
    authorize @invoice
    if @invoice.xero_total_mismatch?
      @xero_invoice = @xero.get_invoice(@invoice.xero_invoice_id)
      #get the total of the sent invoice in Xero
      @invoice.add_line_item_for_rounding(@xero_invoice.total)
      @invoice.save
    end
  end

  def update
    authorize @invoice
    update_xero_contacts(params[:invoice][:xero_contact_name], params[:invoice][:xero_contact_id], @invoice, @clients)
    if @invoice.update(invoice_params)
      #If associate wants to update invoice before sending to xero, symphony finds the params update_field and then redirect to the same invoice EDIT page
      if params[:update_field] == "success"
        update_workflow_action_completed(params[:workflow_action_id], current_user)
        redirect_to edit_symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.friendly_id, id: @workflow.invoice.id, workflow_action_id: params[:workflow_action_id]), notice: 'Symphony invoice successfully updated'
      #when invoice updates with the rounding line item, update the invoice in Xero as well
      elsif @invoice.xero_total_mismatch?
        @xero_invoice = @xero.get_invoice(@invoice.xero_invoice_id)
        @update_xero_invoice = @xero.updating_invoice_payable(@xero_invoice, @invoice.line_items)
        # After updating, update inv status to rounding_added
        @invoice.rounding
        @invoice.save
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
      # If invoice already sent to xero and there is no mismatch
      elsif @invoice.workflow.batch.present? && params[:workflow_action_id].present?
        #set completed task
        update_workflow_action_completed(params[:workflow_action_id], current_user) if @invoice.xero_awaiting_approval? or @invoice.xero_approved?
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
      @delete_invoice.status = (@delete_invoice.status == "SUBMITTED") ? "DELETED" : "VOIDED"
      @delete_invoice.save
    end
    @invoice.destroy!
    @batch = @workflow.batch
    respond_to do |format|
      flash[:notice] = "Invoice has been deleted successfully."
      @batch.present? ? (format.html { redirect_to symphony_batch_path(batch_template_name: @batch.template.slug, id: @batch.id) }) : (format.html { redirect_to symphony_workflow_path(@workflow.template.slug, @workflow.friendly_id) })
    end
  end

  def reject
    invoice_id = params[:id]
    # invoice_id is blank = NEW invoice page
    if invoice_id.blank?
      @invoice = Invoice.new
      @invoice.workflow_id = @workflow.id
      @invoice.user_id = current_user.id
      @invoice.company_id = @company.id
      @invoice.invoice_type = params[:invoice_type]
    else
      # This is from EDIT invoice page
      @invoice = Invoice.find(invoice_id)
    end
    authorize @invoice
    if @invoice.save(validate: false)
      # Check if invoice can be rejected using AASM
      if @invoice.may_reject?
        @invoice.remarks = params[:invoice][:remarks]
        flash[:notice] = "Invoice has been rejected."
        @invoice.reject
        @invoice.save(validate: false)
        if @invoice.workflow.batch.present?
          #set completed task
          update_workflow_action_completed(params[:workflow_action_id], current_user)
          #go to the next invoice
          redirect_to_next_action(@workflow, params[:workflow_action_id])
        else
          redirect_to symphony_workflow_path(@invoice.workflow.template.slug, @invoice.workflow.friendly_id)
        end
      else
        invoice_id.present? ? (render :edit) : (render :new)
      end
    else
      invoice_id.present? ? (render :edit) : (render :new)
    end
  end

  def next_invoice
    next_wf = @workflow.batch.next_workflow(@workflow)
    next_wf_action = next_wf.workflow_actions.where(completed: false).first
    next_wf_action ||= next_wf.workflow_actions.where(completed: true).last
    next_wf_action.present? ? (render_action_invoice(next_wf, next_wf_action)) : (redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id))
  end

  def prev_invoice
    prev_wf = @workflow.batch.previous_workflow(@workflow)
    if prev_wf.present?
      # check if previous workflow have invoice and is that invoice xero total mismatch? if yes go to previous page if not go to first invoice
      (prev_wf.invoice.present? and prev_wf.invoice.xero_total_mismatch?) ? (render_action_invoice(prev_wf, prev_wf.workflow_actions.where(completed: true).last)) : (render_action_invoice(prev_wf, prev_wf.workflow_actions.where(completed: false).first))
    else
      redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id)
    end
  end

  def next_show_invoice
    next_workflow_invoice = @workflow_invoices.where('workflows.created_at > ?', @workflow.created_at).order(created_at: :asc).first
    next_workflow_invoice ||= @workflow_invoices.where('workflows.created_at < ?', @workflow.created_at).order(created_at: :asc).first
    # redirect page
    next_workflow_invoice.present? ? (redirect_to symphony_invoice_path(workflow_name: next_workflow_invoice.template.slug, workflow_id: next_workflow_invoice.id, id: next_workflow_invoice.invoice.id)) : (redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id))
  end

  def prev_show_invoice
    prev_workflow_invoice = @workflow_invoices.where('workflows.created_at < ?', @workflow.created_at).order(created_at: :asc).last
    prev_workflow_invoice ||= @workflow_invoices.where('workflows.created_at > ?', @workflow.created_at).order(created_at: :asc).last
    # redirect page
    prev_workflow_invoice.present? ? (redirect_to symphony_invoice_path(workflow_name: prev_workflow_invoice.template.slug, workflow_id: prev_workflow_invoice.id, id: prev_workflow_invoice.invoice.id)) : (redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id))
  end

  def get_document_analysis
    generate_textract = GenerateTextract.new(@document.id).run_analyze
    respond_to do |format|
      format.json  { render json: generate_textract }
    end
  end

  def get_xero_details_json
    respond_to do |format|
      format.json  { render :json => [{"accounts": @full_account_code}, {"taxes": @full_tax_code}, {"tracking_categories_1": @tracking_categories_1},  {"tracking_categories_2": @tracking_categories_2}, {"items": @items}] }
    end
  end

  private
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def set_workflow
    @workflow = @company.workflows.find(params[:workflow_id])
  end

  def set_show_invoice_navigation
    # check if workflow have batch
    if @workflow.batch.present?
      workflows = @workflow.batch.workflows.order(created_at: :asc)
      @workflow_invoices= @workflow.batch.workflows.includes(:invoice).where.not(invoices: {id: nil}).where.not(invoices: {id: @workflow.invoice.id})
    else
      workflows = Array(@workflow)
      @workflow_invoices= policy_scope(Workflow).includes(:invoice).where.not(invoices: {id: nil}).where.not(invoices: {id: @workflow.invoice.id})
    end

    @total_workflows = workflows.count
    @current_position = workflows.pluck('id').index(@workflow.id)+1
  end

  def set_workflows_navigation
    @workflow_action = @workflow.workflow_actions.find(params[:workflow_action_id])
    # check if workflow have batch
    if @workflow.batch.present?
      @workflows = @workflow.batch.workflows.includes(workflow_actions: :task).where(workflow_actions: {tasks: {id: @workflow_action.task_id}}).order(created_at: :asc)
      @total_completed_task = @workflow.batch.workflows.includes(workflow_actions: :task).where(workflow_actions: {tasks: {id: @workflow_action.task_id}, completed: true}).count
    else
      @workflows = Array(@workflow_action.workflow)
      @total_completed_task = policy_scope(Workflow).where(id: @workflow_action.workflow.id, completed: true).count
    end
    @total_task = @workflows.count

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
      # @page_count = MiniMagick::Image.open(@document.raw_file.service_url).pages.count
      @previous_document = @documents.where('id < ?', @document.id).first
      @next_document = @documents.where('id > ?', @document.id).last
    end
  end

  def set_last_workflow_action
    @last_workflow_action = @workflow.workflow_actions.includes(:task).where(completed: false).order("tasks.position ASC").first&.id
  end

  def get_xero_details
    @invoice_params = {
      invoice_type: params[:invoice_type],
      workflow_action_id: params[:workflow_action_id],
      workflow_name: params[:workflow_name],
      workflow_id: params[:workflow_id]
    }
    # Check if company is connected to xero
    if @company.session_handle.nil?
      redirect_to connect_to_xero_path(xero_connects_from: @invoice_params)
    else
      @xero = Xero.new(current_user.company)
      @clients                = @company.xero_contacts
      # Combine account codes and account names as a string
      @full_account_code      = @xero.get_accounts.map{|account| (account.code + ' - ' + account.name) if account.code.present?} #would not display account if account.code is missing
      @full_tax_code          = @xero.get_tax_rates.map.map{|t| [t.name + ' (' + t.display_tax_rate.to_s + '%) - ' + t.tax_type, {'data-rate': "#{t.display_tax_rate}"}] } # Combine tax codes and tax names as a string
      @currencies             = @xero.get_currencies
      @tracking_name          = current_user.company.xero_tracking_categories
      @tracking_categories_1  = @tracking_name[0]&.options&.map{|option| JSON.parse(option)}
      @tracking_categories_2  = @tracking_name[1]&.options&.map{|option| JSON.parse(option)}
      @items                  = @company.xero_line_items.map{|item| (item.item_code + ': ' + (item.description || '-')) if item.item_code.present?}
    end
  end

  def invoice_params
    params.require(:invoice).permit(:invoice_date, :due_date, :workflow_id, :workflow_action_id, :line_amount_type, :invoice_type, :xero_invoice_id, :invoice_reference, :xero_contact_id, :xero_contact_name, :currency, :status, :subtotal, :total, :user_id, :remarks, line_items_attributes: [:item, :description, :quantity, :price, :account, :tax, :tracking_option_1, :tracking_option_2, :amount, :_destroy])
  end
end
