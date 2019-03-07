class Symphony::InvoicesController < ApplicationController
  include Adapter
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_invoice, only: [:edit, :update, :show]
  before_action :set_workflow, only: [:new, :create, :show, :edit, :update]
  before_action :set_documents
  before_action :get_account_and_tax, only: [:new, :create, :edit, :update]

  rescue_from Xeroizer::OAuth::TokenExpired, Xeroizer::OAuth::TokenInvalid, with: :xero_login

  def new
    @invoice = Invoice.new
    @invoice.build_line_item
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.workflow_id = @workflow.id
    respond_to do |format|
      if @invoice.save
        format.html{redirect_to symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_identifier: @workflow.identifier, id: @invoice.id), notice: "Invoice created successfully!"}
        format.json{render :show, status: :ok, location: @invoice}
      else
        format.html{ redirect_to symphony_workflow_path(workflow_identifier: @invoice.workflow.identifier) }
        format.json{render json: @invoice.errors, status: :unprocessable_entity}
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html{redirect_to symphony_invoice_path(workflow_name: @workflow.template.slug, workflow_identifier: @workflow.identifier, id: @invoice.id), notice: "Invoice updated successfully!"}
        format.json{render :show, status: :ok, location: @invoice}
      else
        format.html{render 'new'}
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

  def set_documents
    @documents = @workflow.documents.where(workflow_id: @workflow.id).order(created_at: :desc)
    unless @documents.empty?
      @document = @documents.where(id: params[:document_id]).exists? ? @documents.find(params[:document_id]) : @documents.last
      @previous_document = @documents.where('id < ?', @document.id).first
      @next_document = @documents.where('id > ?', @document.id).last
    end
  end

  def get_account_and_tax
    @xero = Xero.new(session[:xero_auth])
    @accounts = @xero.get_accounts
    @taxes = @xero.get_tax_rates
  end

  def invoice_params
    params.require(:invoice).permit(:invoice_date, :due_date, :workflow_id, :line_amount_type, :invoice_type, line_items_attributes: [:description, :quantity, :price, :account, :tax, :_destroy])
  end

  def xero_login
    redirect_to user_xero_omniauth_authorize_path
  end
end