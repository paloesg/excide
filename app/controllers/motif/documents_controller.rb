class Motif::DocumentsController < ApplicationController
  layout 'motif/application'
  include Motif::UsersHelper
  include Motif::FoldersHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_document, only: [:update_tags, :update, :destroy]

  after_action :verify_authorized, except: :index

  def index
    @folder = Folder.new
    @folders = get_folders(@user)
    @documents = Document.where(folder_id: nil).order(created_at: :desc).includes(:permissions).where(permissions: { can_view: true, user_id: @user.id })
    @documents = Kaminari.paginate_array(@documents).page(params[:page]).per(5)
    @users = get_users(@company)
    @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
    unless params[:tags].blank?
      if params[:tags] == 'All tags'
        @documents = policy_scope(Document)
      else
        @documents = @documents.select {|document| document.all_tags_list.first == params[:tags]}
      end
    end
    # Filter company is current user's company and have permission can_view, as set in document model's permissions attribute
    @public_key = Algolia.generate_secured_api_key(ENV['ALGOLIASEARCH_API_KEY_SEARCH'], {filters:
      "permissions.users.user_id:#{current_user.id}"
    })
  end

  def new
    @folders = policy_scope(Folder).roots
    company_scope = @company.has_parent? ? [@company, @company.parent, @company.children].flatten.compact : [@company, @company.children].flatten.compact
    @workflow_action = WorkflowAction.where(company_id: company_scope).find(params[:workflow_action_id])
    @folder_id = params[:folder_id]
    @document = Document.new
    authorize @document
  end

  def create
    # multiple file upload from uppy
    if params[:successful_files].present?
      @files = []
      parsed_files = JSON.parse(params[:successful_files])
      MultipleUploadsJob.perform_later(@user, parsed_files, params[:document_type], nil, params[:folder_id])
    # single file upload
    else
      workflow_action = WorkflowAction.find(params[:workflow_action_id])
      @workflow = workflow_action.workflow
      @template = workflow_action.workflow.template
      if params[:document][:folder_id].present?
        @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil, params[:document][:folder_id]).run_without_associations
      else
        @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil, nil).run_without_associations
      end
      if @generate_document.success?
        document = @generate_document.document
        authorize document
        document.update_attributes(workflow_action_id: params[:workflow_action_id], folder_id: params[:document][:folder_id])
        # attach and convert method
        document.attach_and_convert_document(params[:response_key])
      end
    end
    respond_to do |format|
      if params[:folder_id].present?
        # Redirect when generated documents inside folders
        format.html { redirect_to motif_folder_path(id: params[:folder_id]), notice: "Your files are being processed. Please refresh the page to view the uploaded files."  }
        format.json { render json: @files.to_json }
      else
        workflow_action = WorkflowAction.find(params[:workflow_action_id]) if params[:workflow_action_id].present?
        format.html {
          # Redirect to workflow page if wfa_id is present. Else go to documents INDEX page
          params[:workflow_action_id].present? ? (redirect_to motif_outlet_workflow_path(outlet_id: workflow_action.workflow.outlet.id, id: workflow_action.workflow.id), notice: "File was successfully uploaded")
            : (redirect_to motif_documents_path, notice: "File was successfully uploaded")
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

  def show_document
    @document = Document.find(params[:id])
  end

  def document_drawer
    @users = get_users(@company)
    @document = Document.find(params[:id])
    @activities = @activities = PublicActivity::Activity.order("created_at desc").where(trackable_type: "Document").first(10)
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
