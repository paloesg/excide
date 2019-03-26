class Symphony::InvoicesController < ApplicationController
  include Adapter
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_invoice, only: [:edit, :update, :show]
  before_action :set_workflow, only: [:new, :create, :show, :edit, :update]
  before_action :set_documents
  before_action :set_company
  before_action :get_xero_details, only: [:new, :create, :edit, :update, :show]

  rescue_from Xeroizer::OAuth::TokenExpired, Xeroizer::OAuth::TokenInvalid, with: :xero_login

  def new
    @invoice = Invoice.new
    @invoice.build_line_item
    @xero = Xero.new(session[:xero_auth])
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.workflow_id = @workflow.id
    if @invoice.xero_contact_id.present?
      @invoice.xero_contact_name = @xero.get_contact(@invoice.xero_contact_id).name
    else
      #if invoice.xero_contact_id is not present, then create a contact in Xero
      contact_id = @xero.create_contact(name: @invoice.xero_contact_name)
      @invoice.xero_contact_id = contact_id
    end

    respond_to do |format|
      if @invoice.save
        format.html{redirect_to symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_identifier: @workflow.identifier, id: @invoice.id), notice: "Invoice created successfully! " }
        format.json{render :show, status: :ok, location: @invoice}
      else
        format.html{ redirect_to symphony_workflow_path(workflow_identifier: @invoice.workflow.identifier), alert: "Invoice was not created successfully: " + @invoice.errors.full_messages.to_sentence }
        format.json{ render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    @xero = Xero.new(session[:xero_auth])
    if params[:invoice][:xero_contact_name].blank?
      @invoice.xero_contact_name = @xero.get_contact(params[:invoice][:xero_contact_id]).name
    else
      contact_id = @xero.create_contact(name: params[:invoice][:xero_contact_name])
      @invoice.xero_contact_id = contact_id
    end
    @invoice.save
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html{redirect_to symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_identifier: @workflow.identifier, id: @invoice.id), notice: "Invoice updated successfully!"}
        format.json{render :show, status: :ok, location: @invoice}
      else
        format.html{ redirect_to symphony_workflow_path(workflow_identifier: @invoice.workflow.identifier), alert: "Invoice was not successfully save: " + @invoice.errors.full_messages.to_sentence }
        format.json{render json: @invoice.errors, status: :unprocessable_entity}
      end
    end
  end

  def show
    @total = @invoice.total_amount
  end

  private
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def set_workflow
    @workflow = Workflow.find_by(identifier: params[:workflow_identifier])
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
    @xero = Xero.new(session[:xero_auth])
    @clients = @xero.get_contacts
    @accounts = @xero.get_accounts
    @taxes = @xero.get_tax_rates
    @currencies = @xero.get_currencies
    @tracking_name = @xero.get_tracking_options
    @tracking_categories_1 = @tracking_name[0]&.options&.map{|option| option}
    @tracking_categories_2 = @tracking_name[1]&.options&.map{|option| option}
  end

  def invoice_params
    params.require(:invoice).permit(:invoice_date, :due_date, :workflow_id, :line_amount_type, :invoice_type, :xero_invoice_id, :invoice_reference, :xero_contact_id, :xero_contact_name, :currency, line_items_attributes: [:description, :quantity, :price, :account, :tax, :tracking_option_1, :tracking_option_2, :_destroy])
  end

  def xero_login
    redirect_to user_xero_omniauth_authorize_path
  end
end