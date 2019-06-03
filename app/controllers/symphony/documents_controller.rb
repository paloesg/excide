class Symphony::DocumentsController < DocumentsController
  before_action :set_templates, only: [:new, :edit]
  before_action :set_company_workflows, only: [:new, :edit]
  before_action :set_workflow, only: [:new]

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
    @document = Document.new
    authorize @document
  end

  def edit
    authorize @document

    @workflow = @workflows.find(@document.workflow_id) if @document.workflow_id.present?
  end

  def create
    @document = Document.new(document_params)
    authorize @document

    @document.company = @company
    @document.user = @user
    @document.document_template = DocumentTemplate.find_by(title: 'Invoice') if params[:document_type] == 'invoice'
    if params[:workflow].present?
      @workflow = Workflow.find_by(identifier: params[:workflow])
      @document.workflow = @workflow
    end

    respond_to do |format|
      if @document.save
        if params[:document_type] == 'batch-uploads'
          @template = Template.find(params[:document][:template_id])
          @workflow = Workflow.new(user: current_user, company: @company, template: @template, identifier: params[:workflow_identifier], workflowable: @client)
          @workflow.template_data(@template)
          #equate workflow to the latest batch
          @workflow.batch = Batch.last
          @workflow.save
          @document.update_attributes(workflow: @workflow)
          format.html { redirect_to @workflow.nil? ? symphony_documents_path : symphony_batch_path(@workflow.template.slug, @workflow.batch_id), notice: params[:count] + ' documents were successfully created.' }
          format.json { render :show, status: :created, location: @document}
        else
          format.html { redirect_to @workflow.nil? ? symphony_documents_path : symphony_workflow_path(@workflow.template.slug, @workflow.identifier), notice: 'Document was successfully created.' }
          format.json { render :show, status: :created, location: @document}
        end
      else
        set_templates

        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @document

    if @document.update(document_params)
      redirect_to symphony_document_path, notice: 'Document was successfully updated.'
    else
      set_templates
      render :edit
    end
  end

  def destroy
    authorize @document

    @document.destroy
    redirect_to symphony_documents_path, notice: 'Document was successfully destroyed.'
  end

  def upload_invoice
    set_company
    set_company_workflows
    @clients = @company.clients
    @templates = Template.assigned_templates(current_user)
    @s3_direct_post = S3_BUCKET.presigned_post(key: "#{@company.slug}/uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
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
    @workflows = @company.workflows.includes(template: [{ sections: [{ tasks: :role }] }])
  end

  def set_workflow
    @workflow = @workflows.find_by(identifier: params[:workflow]) if params[:workflow].present?
  end
end
