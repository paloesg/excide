class Symphony::DocumentsController < ApplicationController
  layout 'dashboard/application'
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_templates, only: [:new, :edit, :multiple_edit]
  before_action :set_company_workflows, only: [:new, :edit]
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  after_action :verify_authorized, except: [:index, :search]
  after_action :verify_policy_scoped, only: :index

  def index
    @get_documents = policy_scope(Document).includes(:document_template, :workflow)

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
    @generate_document = GenerateDocumentAction.new(@user, @company, params[:workflow], params[:workflow_action], document_params, params[:document_type], params[:document][:template_id], params[:batch_id]).run

    authorize @generate_document.document
    respond_to do |format|
      if @generate_document.success?
        if params[:document_type] == 'batch-uploads'
          document = @generate_document.document
          batch = document.workflow.batch
          first_task = batch.template&.sections.first.tasks.first

          # A link for redirect to invoice page if task type is "create invoice payable" or "create invoice receivable", for others task type will go to batch show page
          if ['create_invoice_payable', 'create_invoice_receivable'].include? first_task.task_type
            link = new_symphony_invoice_path(workflow_name: document.workflow.template.slug, workflow_id: batch.workflows.first, workflow_action_id: batch.workflows.first.workflow_actions.first.id, invoice_type: "#{first_task.task_type == 'create_invoice_payable' ? 'payable' : 'receivable' }")
          else
            link = symphony_batch_path(batch_template_name: document.workflow.template.slug, id: document.workflow.batch)
          end

           #return output in json
          output = { link_to: link, status: "ok", message: "batch documents created", document: document.id, batch: batch.id, template: document.workflow.template.slug }
          flash[:notice] = "New batch of #{Batch.find(params[:batch_id]).workflows.count} documents successfully created!"
          format.json  { render :json => output }
        elsif params[:upload_type] == "batch_upload"
          @batch = @document.workflow.batch
          workflow_action = WorkflowAction.find(params[:workflow_action])
          if workflow_action.update_attributes(completed: true, completed_user_id: current_user.id)
            format.html {redirect_to symphony_batch_path(batch_template_name: @batch.template.slug, id: @batch.id), notice: "#{@workflow_action.task.instructions} done!"}
          else
            format.json { render json: workflow_action.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to @generate_document.document.workflow.nil? ? symphony_documents_path : symphony_workflow_path(@generate_document.document.workflow.template.slug, @generate_document.document.workflow.id), notice: 'Document was successfully created.' }
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
    params[:url_files].each do |url_file|
      document = Document.new(file_url: url_file)
      document.company = @company
      document.user = @user
      document.save
      @files.append document
      authorize document
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

    @document.destroy
    redirect_to symphony_documents_path, notice: 'Document was successfully destroyed.'
  end

  private

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
    params.require(:document).permit(:filename, :remarks, :company_id, :date_signed, :date_uploaded, :file_url, :workflow_id, :document_template_id)
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "#{@company.slug}/uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end
