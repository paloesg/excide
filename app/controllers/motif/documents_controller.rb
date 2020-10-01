class Motif::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @folders = policy_scope(Folder).roots
    @documents = policy_scope(Document).where(folder_id: nil)
  end

  def new
  end

  def create
    @files = []
    parsed_files = JSON.parse(params[:successful_files])
    parsed_files.each do |file|
      @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil).run 
      document = @generate_document.document
      authorize document
      # attach and convert method with the response key to create blob
      document.attach_and_convert_document(file['response']['key'])
      @files.append document
    end
    respond_to do |format|
      format.html { redirect_to motif_documents_path files: @files }
      format.json { render json: @files.to_json }
    end
  end

  def update
    @document = @company.documents.find(params[:document_id])
    authorize @document
    @folder = @company.folders.find(params[:folder_id])
    respond_to do |format|
      if @document.update(folder_id: @folder.id)
        format.json { render json: { link_to: motif_documents_path, status: "ok" } }
      else
        format.html { redirect_to motif_documents_path }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end
end
