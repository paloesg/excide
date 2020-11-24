class Motif::DocumentsController < ApplicationController
  layout 'motif/application'
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_document, only: [:update_tags, :update, :destroy]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @folder = Folder.new
    @folders = policy_scope(Folder).roots
    @documents = policy_scope(Document).where(folder_id: nil).order(created_at: :desc).includes(:permissions)
    @users = @company.users.includes(:permissions)
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
    @workflow_action = @company.workflow_actions.find(params[:workflow_action]) if params[:workflow_action].present?
    @workflow_action_id = params[:workflow_action_id]
    @document = Document.new
    authorize @document
  end

  def create
    # multiple file upload from uppy
    if params[:successful_files].present?
      @files = []
      parsed_files = JSON.parse(params[:successful_files])
      parsed_files.each do |file|
        @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil, params[:folder_id]).run
        document = @generate_document.document
        authorize document
        # attach and convert method with the response key to create blob
        document.attach_and_convert_document(file['response']['key'])
        @files.append document
      end
    # single file upload
    else 
      @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil, nil).run_without_associations
      if @generate_document.success?
        document = @generate_document.document
        document.update_attributes(workflow_action_id: params[:workflow_action_id])
        authorize document
        # attach and convert method
        document.attach_and_convert_document(params[:response_key])
      end
    end
    # create permission on creation of document for the user that uploaded it
    Permission.create(user: @user, can_write: true, can_download: true, can_view: true, permissible: document)
    respond_to do |format|
      workflow_action = WorkflowAction.find(params[:workflow_action_id])
      @template = workflow_action.workflow.template
      # Redirect when generated documents from workflow actions
      if params[:workflow_action_id].present?
        format.html { 
          params[:workflow_action_id].present? ? (redirect_to edit_motif_template_path(@template), notice: "Member has been added into this outlet")
            : (redirect_to motif_documents_path, notice: "File was successfully uploaded.")
        }
      # Redirect when generated documents inside folders
      elsif params[:folder_id].present?
        format.html { params[:folder_id].present? ? (redirect_to motif_folder_path(id: params[:folder_id])) : (redirect_to motif_documents_path files: @files) }
        format.json { render json: @files.to_json }
      end
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
  def set_company
    @user = current_user
    @company = @user.company
  end

  def set_document
    @document = @company.documents.find(params[:id])
  end
end
