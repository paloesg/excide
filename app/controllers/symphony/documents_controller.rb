class Symphony::DocumentsController < ApplicationController
  # layout 'dashboard/application'
  layout 'metronic/application'

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
    generated_document = @generate_document.document
    authorize generated_document
    respond_to do |format|
      if @generate_document.success?
        d = Document.find_by(id: generated_document.id)
        # Only generate textract ID if the workflow contains the task 'create_invoice payable' or 'create_invoice_receivable'. Check for workflow present in case user uploads using document NEW page instead.
        @generate_textract = GenerateTextract.new(generated_document.id).run_generate if d.workflow&.workflow_actions&.any?{|wfa| wfa.task.task_type == 'create_invoice_payable' or wfa.task.task_type == 'create_invoice_receivable'}
        # Run convert job asynchronously. Service object is performed during the job.
        ConvertPdfToImagesJob.perform_later(generated_document)
        # Upload in batches dropzone
        if params[:document_type] == 'batch-uploads'
          batch = generated_document.workflow.batch
          first_task = batch.template&.sections.first.tasks.first
          first_workflow = batch.workflows.order(created_at: :asc).first

          # A link for redirect to invoice page if task type is "create invoice payable" or "create invoice receivable" and workflow actions of first workflow should be created
          if ['create_invoice_payable', 'create_invoice_receivable'].include? first_task.task_type and first_workflow.workflow_actions.present?
            link = new_symphony_invoice_path(workflow_name: generated_document.workflow.template.slug, workflow_id: first_workflow.id, workflow_action_id: first_workflow.workflow_actions.first, invoice_type: "#{first_task.task_type == 'create_invoice_payable' ? 'payable' : 'receivable' }")
          else
            link = symphony_batch_path(batch_template_name: generated_document.workflow.template.slug, id: document.workflow.batch)
          end
           #return output in json
          output = { link_to: link, status: "ok", message: "batch documents created", document: generated_document.id, batch: batch.id, template: generated_document.workflow.template.slug }
          flash[:notice] = "New batch of #{Batch.find(params[:batch_id]).workflows.count} documents successfully created!"
          format.json  { render :json => output }
        # Upload in workflow action with task type: upload file for batches
        elsif params[:upload_type] == "batch_upload"
          @batch = @document.workflow.batch
          workflow_action = WorkflowAction.find(params[:workflow_action])
          if workflow_action.update_attributes(completed: true, completed_user_id: current_user.id)
            format.html {redirect_to symphony_batch_path(batch_template_name: @batch.template.slug, id: @batch.id), notice: "#{@workflow_action.task.instructions} done!"}
          else
            format.json { render json: workflow_action.errors, status: :unprocessable_entity }
          end
        else
          # the OR statement is to check that document is uploaded from document NEW pass the ternary condition
          format.html { redirect_to generated_document.workflow.nil? ? symphony_documents_path : symphony_workflow_path(generated_document.workflow.template.slug, generated_document.workflow.id), notice: 'Document was successfully created.' }
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

    if @document.destroy
      redirect_to symphony_documents_path
      respond_to do |format|
        format.html { redirect_to symphony_document_path, notice: 'Document was successfully deleted.' }
        format.js  { flash[:notice] = 'Document was successfully deleted.' }
      end
    end
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
    params.require(:document).permit(:filename, :remarks, :company_id, :date_signed, :date_uploaded, :file_url, :workflow_id, :document_template_id, converted_image: [])
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "#{@company.slug}/uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end
