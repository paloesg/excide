class Symphony::InvoicesController < ApplicationController
  include Adapter
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company, except: [:get_xero_item_code_detail]
  before_action :set_workflow, except: [:get_xero_item_code_detail]
  before_action :set_workflows_navigation, only: [:new, :create, :edit]
  before_action :set_last_workflow_action, only: [:show]
  before_action :set_documents, except: [:get_xero_item_code_detail]
  before_action :set_invoice, only: [:edit, :update, :show, :destroy]
  before_action :get_xero_details

  rescue_from Xeroizer::OAuth::TokenInvalid, with: :xero_login
  rescue_from Xeroizer::RecordInvalid, Xeroizer::ApiException, URI::InvalidURIError, ArgumentError, Xeroizer::OAuth::RateLimitExceeded, with: :xero_error

  after_action :verify_authorized, except: [:create, :index, :get_xero_item_code_detail]
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
        workflow_action = WorkflowAction.find(params[:workflow_action_id])
        workflow_action.update_attributes(completed: true, completed_user_id: current_user.id)
        invoice_type = params[:invoice_type].present? ? params[:invoice_type] : @invoice.invoice_type
        next_wf = @workflow.batch.next_workflow(@workflow, workflow_action)
        if next_wf.present? and next_wf.get_workflow_action(workflow_action.task_id).completed == false
          redirect_to new_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, invoice_type: invoice_type, workflow_action_id: next_wf.get_workflow_action(workflow_action.task_id).id), notice: "Invoice #{@current_position} has been saved successfully."
        else
          redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id), notice: "#{workflow_action.task.task_type.humanize} task has been completed."
        end
      else
        redirect_to symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @invoice.id), notice: "Invoice created successfully."
      end
    else
      render 'new'
    end
  end

  def edit
    authorize @invoice
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
    if @invoice.save
      if @invoice.update(invoice_params)
        if @invoice.workflow.batch.present? && params[:workflow_action_id].present?
          workflow_action = WorkflowAction.find(params[:workflow_action_id])
          workflow_action.update_attributes(completed: true, completed_user_id: current_user.id)
          invoice_type = params[:invoice_type].present? ? params[:invoice_type] : @invoice.invoice_type
          next_wf = @workflow.batch.next_workflow(@workflow, workflow_action)
          if next_wf.present? and next_wf.get_workflow_action(workflow_action.task_id).completed == false and next_wf.invoice.present?
            redirect_to edit_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, id: next_wf.invoice.id, workflow_action_id: next_wf.get_workflow_action(workflow_action.task_id).id), notice: "Invoice #{@current_position} has been #{@invoice.status} successfully."
          else
            redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id), notice: "#{workflow_action.task.task_type.humanize} task has been completed."
          end
        else
          redirect_to symphony_invoice_path(workflow_name: @invoice.workflow.template.slug, workflow_id: @invoice.workflow.id, id: @invoice.id, workflow_action_id: params[:workflow_action_id])
        end
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
          workflow_action = WorkflowAction.find(params[:workflow_action_id])
          workflow_action.update_attributes(completed: true, completed_user_id: current_user.id)
          next_wf = @workflow.batch.next_workflow(@workflow, workflow_action)
          if next_wf.present? and next_wf.get_workflow_action(workflow_action.task_id).completed == false
            if invoice_id.present?
              redirect_to edit_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, id: next_wf.invoice.id, workflow_action_id: next_wf.get_workflow_action(workflow_action.task_id).id)
            else
              redirect_to new_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, invoice_type: @invoice.invoice_type, workflow_action_id: next_wf.get_workflow_action(workflow_action.task_id).id)
            end
          else
            redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id)
          end
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

    @remaining_invoices = @total_task - @total_completed_task - 1

    @current_position = @workflows.pluck('id').index(@workflow.id)+1

    incomplete_workflows = @workflow.batch.workflows.includes(workflow_actions: :task).where(workflow_actions: {tasks: {id: @workflow_action.task_id}, completed: false}).order(created_at: :asc)

    # When on edit page the workflow filter only have invoice
    if params[:action] == "edit"
      incomplete_workflows = incomplete_workflows.includes(:invoice).where.not(invoices: {id: nil})
    end

    @next_workflow = incomplete_workflows.where('workflows.created_at > ?', @workflow.created_at).first
    @previous_workflow = incomplete_workflows.where('workflows.created_at < ?', @workflow.created_at).last
  end

  def set_last_workflow_action  
    @last_workflow_action = @workflow.workflow_actions.includes(:task).where(completed: false).order("tasks.position ASC").first&.id
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

  def xero_login
    @xero_client = Xeroizer::PartnerApplication.new(ENV["XERO_CONSUMER_KEY"], ENV["XERO_CONSUMER_SECRET"], "| echo \"#{ENV["XERO_PRIVATE_KEY"]}\" ")
    request_token = @xero_client.request_token(oauth_callback: ENV['ASSET_HOST'] + '/xero_callback_and_update')
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to request_token.authorize_url
  end

  def xero_error(e)
    message = 'Xero returned an error: ' + e.message + '. Please ensure you have filled in all the required data in the right format.'
    Rails.logger.error("Xero Error: #{message}")
    redirect_to session[:previous_url], alert: message
  end

  def render_action_create_invoice(wf_data)
    invoice_type = params[:invoice_type].present? ? params[:invoice_type] : @workflow.invoice.invoice_type
    if wf_data.invoice.blank?
      redirect_to new_symphony_invoice_path(workflow_name: wf_data.template.slug, workflow_id: wf_data.id, invoice_type: invoice_type)
    elsif wf_data.invoice.present?
      redirect_to edit_symphony_invoice_path(workflow_name: wf_data.template.slug, workflow_id: wf_data.id, id: @invoice.id)
    end
  end
end
