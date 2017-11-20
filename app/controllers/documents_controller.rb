class DocumentsController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  # GET /documents
  # GET /documents.json
  def index
    @documents = @company.documents
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)
    @document.company = @company

    if @document.save
      redirect_to (current_user.has_role? :admin) ? admin_company_documents_path(@company.id) : documents_path, notice: 'Document was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    if @document.update(document_params)
      redirect_to (current_user.has_role? :admin) ? admin_company_documents_path(@company.id) : documents_path, notice: 'Document was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      redirect_to (current_user.has_role? :admin) ? admin_company_documents(@company.id) : documents_path, notice: 'Document was successfully destroyed.'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @user = current_user

    if current_user.has_role? :admin
      @companies = Company.all
      @company = Company.friendly.find(params[:company_name])
    elsif params[:company_name].present?
      @company = @user.company
      redirect_to dashboard_path
    else
      @company = @user.company
    end
  end

  def set_document
    @document = @company.documents.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:filename, :remarks, :company_id, :date_signed, :date_uploaded, :file_url)
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end
