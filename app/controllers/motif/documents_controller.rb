class Motif::DocumentsController < ApplicationController
  before_action :set_company
  before_action :authenticate_user!

  def index
    @get_documents = Document.where(company: @company) #currently its only what the user uploaded
    @get_root_folders = Folder.where(company: @company, ancestry: nil)
    @templates = policy_scope(Template).assigned_templates(current_user)
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

  private

  def set_company
    @user = current_user
    @company = @user.company
  end
end
