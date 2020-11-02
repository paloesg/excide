class Motif::DocumentsController < ApplicationController
  layout 'motif/application'
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_document, only: [:update_tags, :update, :destroy]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @folders = policy_scope(Folder).roots
    @documents = policy_scope(Document).where(folder_id: nil).order(created_at: :desc)
    @roles = @company.roles.includes(:permissions)
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    unless params[:tags].blank?
      if params[:tags] == 'All tags'
        @documents = policy_scope(Document)
      else
        @documents = @documents.select {|document| document.all_tags_list.first == params[:tags]}
      end
    end
  end

  def new
    @document = Document.new
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

  def update_tags
    authorize @document
    @tags = []
    params[:values].each{|key, tag| @tags << tag[:value]} unless params[:values].blank?
    @company.tag(@document, with: @tags, on: :tags)
    respond_to do |format|
      format.json { render json: @company.owned_tags.pluck(:name), status: :ok }
    end
  end

  def update
    authorize @document
    @folder = @company.folders.find(params[:folder_id]) if params[:folder_id].present?
    respond_to do |format|
      # check if update comes from drag and drop or from remarks. If folder_id is not present, then update remarks
      if (params[:folder_id].present? ? @document.update(folder_id: @folder.id) : @document.update(remarks: params[:document][:remarks]))
        format.json { render json: { link_to: motif_documents_path, status: "ok" } }
      else
        format.html { redirect_to motif_documents_path }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @document
    if @document.destroy
      respond_to do |format|
        format.html { redirect_to motif_documents_path }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Document was successfully deleted.'
    end
  end

  private

  def set_document
    @document = @company.documents.find(params[:id])
  end
end
