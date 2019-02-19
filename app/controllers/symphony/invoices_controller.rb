class Symphony::InvoicesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_workflow, only: [:new, :create]
  before_action :set_documents

  def new
    @invoice = Invoice.new
    @invoice.build_lineitems
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.invoice_identifier = "Link to Xero later on!"
    respond_to do |format|
      if @invoice.save
        format.html{redirect_to root_path, notice: "Invoice created successfully!"}
        format.json{render :show, status: :ok, location: @invoice}
      else
        format.html{render 'new'}
        format.json{render json: @invoice.errors, status: :unprocessable_entity}
      end
    end
  end

  private
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

  def invoice_params
    params.require(:invoice).permit(:invoice_identifier, :invoice_date, :due_date, line_items: [:description, :quantity, :price, :account])
  end

end