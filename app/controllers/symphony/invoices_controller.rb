class Symphony::InvoicesController < ApplicationController
  include Adapter
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company, except: [:get_xero_item_code_detail]
  before_action :set_workflow, except: [:get_xero_item_code_detail]
  before_action :set_documents, except: [:get_xero_item_code_detail]
  before_action :set_invoice, only: [:edit, :update, :show, :destroy]
  before_action :get_xero_details

  rescue_from Xeroizer::OAuth::TokenExpired, Xeroizer::OAuth::TokenInvalid, with: :xero_login

  after_action :verify_authorized, except: [:index, :get_xero_item_code_detail]
  after_action :verify_policy_scoped, only: :index

  def new
    @invoice = Invoice.new
    authorize @invoice

    @invoice.build_line_item
    @xero = Xero.new(session[:xero_auth])
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
        redirect_to symphony_batch_path(batch_template_name: @workflow.batch.template.slug, id: @workflow.batch.id), notice: "Invoice created successfully!"
      else
        redirect_to symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @invoice.id), notice: "Invoice created successfully!"
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
    @xero = Xero.new(session[:xero_auth])
    if params[:invoice][:xero_contact_name].blank?
      @invoice.xero_contact_name = @xero.get_contact(params[:invoice][:xero_contact_id]).name
    else
      contact_id = @xero.create_contact(name: params[:invoice][:xero_contact_name])
      @invoice.xero_contact_id = contact_id
    end
    @invoice.save
    if @invoice.update(invoice_params)
      redirect_to symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_id: @workflow.id, id: @invoice.id)
    else
      render 'edit'
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
    respond_to do |format|
      format.html { redirect_to symphony_workflow_path(@workflow.template.slug, @workflow.id), notice: "Invoice has been deleted successfully."}
    end
  end

  def get_xero_item_code_detail
    @item_code_list = @xero.get_item(params[:item_id])

    @purchase_description = @item_code_list.purchase_description
    @price_code = @item_code_list.sales_details.unit_price

    @get_account = @xero.get_account(@item_code_list.sales_details.account_code)
    @account_code = @get_account.code + ' - ' + @get_account.name

    @get_tax_rate = @xero.get_tax_rate(@item_code_list.sales_details.tax_type)
    @tax_code = @get_tax_rate.name + ' (' + @get_tax_rate.display_tax_rate.to_s + '%) - ' + @get_tax_rate.tax_type

    respond_to do |format|
      if @item_code_list.present?
        format.json { render :json => {item: {:purchase_description => @purchase_description, :price_code => @price_code,
        :account => @account_code, :tax => @tax_code}}}
      else
        format.json { render json: @item_code_list.errors, status: :unprocessable_entity }
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
    @xero                   = Xero.new(session[:xero_auth])
    @clients                = @xero.get_contacts
    # Combine account codes and account names as a string
    @full_account_code      = @xero.get_accounts.map{|account| (account.code + ' - ' + account.name) if account.code.present?} #would not display account if account.code is missing
    @full_tax_code          = @xero.get_tax_rates.map{|tax| tax.name + ' (' + tax.display_tax_rate.to_s + '%) - ' + tax.tax_type} # Combine tax codes and tax names as a string
    @currencies             = @xero.get_currencies
    @tracking_name          = @xero.get_tracking_options
    @tracking_categories_1  = @tracking_name[0]&.options&.map{|option| option}
    @tracking_categories_2  = @tracking_name[1]&.options&.map{|option| option}
    @items                  = @xero.get_items
  end

  def invoice_params
    params.require(:invoice).permit(:invoice_date, :due_date, :workflow_id, :line_amount_type, :invoice_type, :xero_invoice_id, :invoice_reference, :xero_contact_id, :xero_contact_name, :currency, :approved, :total, :user_id, line_items_attributes: [:item, :description, :quantity, :price, :account, :tax, :tracking_option_1, :tracking_option_2, :_destroy])
  end

  def xero_login
    redirect_to user_xero_omniauth_authorize_path
  end
end
