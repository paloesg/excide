class Symphony::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_templates, only: [:new, :edit, :multiple_edit]
  before_action :set_company_workflows, only: [:new, :edit]
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]
  before_action :require_symphony

  after_action :verify_authorized, except: [:index, :search]
  after_action :verify_policy_scoped, only: :index

  def index
    @get_documents = policy_scope(Document).includes(:document_template, :workflow)
    @templates = policy_scope(Template).assigned_templates(current_user)
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
    # TODO: Generate secured api key per user tag, only relevant users are tagged to each workflow.
    @public_key = Algolia.generate_secured_api_key(ENV['ALGOLIASEARCH_API_KEY_SEARCH'], {filters: 'company.slug:' + current_user.company.slug})
  end

  def show
    authorize @document
  end

  def new
    @workflow = @workflows.find(params[:workflow]) if params[:workflow].present?
    @workflow_action = @company.workflow_actions.find(params[:workflow_action]) if params[:workflow_action].present?
    @document = Document.new
    authorize @document
  end

  def edit
    authorize @document

    @workflow = @workflows.find(@document.workflow_id) if @document.workflow_id.present?
  end

  def create
    @generate_document = GenerateDocument.new(@user, @company, params[:document][:template_slug], params[:workflow], params[:workflow_action], params[:document_type], params[:batch_id]).run
    respond_to do |format|
      if @generate_document.success?
        document = @generate_document.document
        authorize document
        # attach and convert method
        document.attach_and_convert_document(params[:response_key])
        # Generate textract ID if the workflow contains the task 'create_invoice payable' or 'create_invoice_receivable'.
        # @generate_textract = GenerateTextract.new(document.id).run_generate if document.workflow&.workflow_actions&.any?{|wfa| wfa.task.task_type == 'create_invoice_payable' or wfa.task.task_type == 'create_invoice_receivable'}
        
        # Upload single file task in workflow and batch!
        if params[:upload_type] == "file-upload-task"
          workflow_action = WorkflowAction.find(params[:workflow_action])
          if workflow_action.update_attributes(completed: true, completed_user_id: current_user.id)
            # If batch is present, redirect to batch page, else go to workflow page
            @batch.present? ? format.html {redirect_to symphony_batch_path(batch_template_name: @batch.template.slug, id: @batch.id)} : format.html{ redirect_to symphony_workflow_path(workflow_action.workflow.template.slug, workflow_action.workflow.id) } 
            flash[:notice] = "#{workflow_action.task.instructions} done!"
          else
            format.json { render json: workflow_action.errors, status: :unprocessable_entity }
          end
        # Upload multiple file task in workflow and batch!
        elsif params[:document_type] == "multiple-file-upload-task"
          workflow = @company.workflows.find(params[:workflow])
          link = workflow.batch.present? ? symphony_batch_path(batch_template_name: workflow.batch.template.slug, id: workflow.batch.id) : symphony_workflow_path(document.workflow.template.slug, document.workflow.id)
          output = { link_to: link, status: "ok" }
          format.json  { render :json => output }
        else
          # For document single file upload
          format.html { redirect_to symphony_documents_path } if document.workflow.nil?
        end
      else
        set_templates
        error_message = "There was an error creating document of batch. Please contact your admin with details of this error: #{@generate_document.message}"
        flash[:alert] = error_message
        if params[:document_type] == 'batch-uploads'
          output = { :status => "error", :message => error_message}
          format.json  { render :json => output }
        else
          format.html { render :new }
        end
      end
    end
  end

  def index_create
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
      format.html { redirect_to multiple_edit_symphony_documents_path files: @files }
      format.json { render json: @files.to_json }
    end
  end

  def multiple_edit
    @documents = Document.where(id: params[:files])
    authorize @documents
  end

  def update
    authorize @document

    if @document.update(document_params)
      respond_to do |format|
        format.html { redirect_to symphony_document_path, notice: 'Document was successfully updated.' }
        format.json { render json: @document }
      end
    else
      set_templates
      format.html { render :edit }
    end
  end

  def destroy
    authorize @document
    if @document.destroy
      respond_to do |format|
        format.html { redirect_to symphony_documents_path }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Document was successfully deleted.'
    end
  end

  private

  # checks if the user's company has Symphony. Links to symphony_policy.rb
  def require_symphony
    authorize :symphony, :index?
  end

  def set_company
    @user = current_user
    @company = @user.company
  end

  def set_templates
    @document_templates = DocumentTemplate.joins(template: :company).where(templates: {company_id: @company.id}).order(id: :asc)
  end

  def set_company_workflows
    @workflows = @company.workflows
  end

  def set_document
    @document = @company.documents.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:filename, :remarks, :company_id, :date_signed, :date_uploaded, :file_url, :workflow_id, :document_template_id, :tag_list, :raw_file, converted_images: [])
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "#{@company.slug}/uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end
