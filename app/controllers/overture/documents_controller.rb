class Overture::DocumentsController < ApplicationController
  layout 'overture/application'
  
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
    @folders = policy_scope(Folder).roots
    @workflow_action = @company.workflow_actions.find(params[:workflow_action]) if params[:workflow_action].present?
    @workflow_action_id = params[:workflow_action_id]
    @folder_id = params[:folder_id]
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
      if params[:document][:folder_id].present?
        @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil, params[:document][:folder_id]).run_without_associations
      else
        @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil, nil).run_without_associations
      end
      if @generate_document.success?
        document = @generate_document.document
        document.update_attributes(workflow_action_id: params[:workflow_action_id])
        if params[:document][:folder_id].present?
          document.update_attributes(folder_id: params[:document][:folder_id])
        end
        authorize document
        # attach and convert method
        document.attach_and_convert_document(params[:response_key])
      end
    end
    # create permission on creation of document for the user that uploaded it
    Permission.create(user: @user, can_write: true, can_download: true, can_view: true, permissible: document)
    respond_to do |format|
      if params[:folder_id].present?
        # Redirect when generated documents inside folders
        format.html { redirect_to overture_folder_path(id: params[:folder_id]), notice: "File(s) successfully uploaded into folder."  }
        format.json { render json: @files.to_json }
      else
        workflow_action = WorkflowAction.find(params[:workflow_action_id]) if params[:workflow_action_id].present?
        format.html {
          # Redirect to workflow page if wfa_id is present. Else go to documents INDEX page
          params[:workflow_action_id].present? ? (redirect_to overture_outlet_workflow_path(outlet_id: workflow_action.workflow.outlet.id, id: workflow_action.workflow.id), notice: "File was successfully uploaded")
            : (redirect_to overture_documents_path, notice: "File was successfully uploaded")
        }
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
        format.json { render json: { link_to: overture_documents_path, status: "ok" } }
      else
        format.html { redirect_to overture_documents_path }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @document
    if @document.destroy
      respond_to do |format|
        format.html { redirect_to overture_documents_path }
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
