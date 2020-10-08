class Motif::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @folders = policy_scope(Folder).roots
    @documents = policy_scope(Document).order(created_at: :desc)
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
      # create permission on creation of document for all the user's roles in that company
      @user.roles.where(resource_id: @company.id).each do |role|
        Permission.create(role: role, can_write: true, can_download: true, can_view: true, permissible: document)
      end
    end
    respond_to do |format|
      format.html { redirect_to motif_documents_path files: @files }
      format.json { render json: @files.to_json }
    end
  end

  def update_tags
    @document = @company.documents.find(params[:id])
    authorize @document
    @tags = []
    params[:values].each{|key, tag| @tags << tag[:value]} unless params[:values].blank?
    @company.tag(@document, with: @tags, on: :tags)
    respond_to do |format|
      format.json { render json: @company.owned_tags.pluck(:name), status: :ok }
    end
  end
  
  private

  def set_company
    @user = current_user
    @company = @user.company
  end
end
