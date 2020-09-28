class Motif::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @folders = policy_scope(Folder).roots
    @documents = policy_scope(Document)
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

  def drag_documents_to_folder
    @document = @company.documents.find(params[:document_id])
    @folder = @company.folders.find(params[:folder_id])
    @folder.documents << @document
    respond_to do |format|
      format.json { render json: "all good?", status: :ok }
    end
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end
end
