class Symphony::DocumentsController < DocumentsController
  before_action :set_templates, only: [:new, :edit, :multiple_edit]
  before_action :set_company_workflows, only: [:new, :edit]
  before_action :set_workflow, only: [:new]
  before_action :set_workflow_action, only: [:new]

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
      @workflow = @company.workflows.find(params[:workflow])
      @document.workflow = @workflow
    end

    if params[:workflow_action].present?
      @workflow_action = @company.workflow_actions.find(params[:workflow_action])
      @document.workflow_action = @workflow_action
    end

    if params[:document_type] == 'batch-uploads'
      @template = Template.find(params[:document][:template_id])
      @workflow = Workflow.new(user: current_user, company: @company, template: @template, workflowable: @client)
      @workflow.template_data(@template)
      #equate workflow to the latest batch
      @workflow.batch = Batch.last
      @workflow.save
      @document.workflow = @workflow
    end

    respond_to do |format|
      if @document.save
        if params[:document_type] == 'batch-uploads'
           #return output in json
          output = { :status => "ok", :message => "batch documents created", :document => @document.id, :batch => @workflow.batch.id, :template => @template.slug}
          format.json  { render :json => output }
        else
          format.html { redirect_to @workflow.nil? ? symphony_documents_path : symphony_workflow_path(@workflow.template.slug, @workflow.id), notice: 'Document was successfully created.' }
          format.json { render :show, status: :created, location: @document}
        end
      else
        set_templates

        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def index_create
    @files = []
    set_company
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

  def upload_invoice
    set_company
    set_company_workflows
    @clients = @company.clients
    @templates = Template.assigned_templates(current_user)
    @s3_direct_post = S3_BUCKET.presigned_post(key: "#{@company.slug}/uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end

  private

  def create_workflow(company, template_id, workflow_identifier, client, document)
    @template = Template.find(template_id)
    @workflow = Workflow.new(user: current_user, company: company, template: @template, identifier: workflow_identifier, workflowable: client)
    @workflow.template_data(@template)
    #equate workflow to the latest batch
    @workflow.batch = Batch.last
    @workflow.save
    Document.find(document.id).update_attributes(workflow: @workflow)
  end

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
    @workflow = @workflows.find(params[:workflow]) if params[:workflow].present?
  end

  def set_workflow_action
    @workflow_action = @company.workflow_actions.find(params[:workflow_action]) if params[:workflow_action].present?
  end
end
