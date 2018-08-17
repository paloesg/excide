class Symphony::DocumentsController < DocumentsController
  before_action :set_templates, only: [:index, :new, :edit]
  before_action :set_company_workflows, only: [:index, :new, :edit]
  before_action :set_workflow, only: [:new]

  def index
    @documents = Kaminari.paginate_array(@company.documents.order(created_at: :desc)).page(params[:page]).per(20)
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end

  def edit
    @workflow = @workflows.find(@document.workflow_id) if @document.workflow_id.present?
  end

  def create
    @document = Document.new(document_params)
    @document.company = @company
    @document.user = @user
    @document.document_template = DocumentTemplate.find_by(title: 'Invoice') if params[:document_type] == 'invoice'

    @workflow = Workflow.find_by(identifier: params[:workflow]) if params[:workflow].present?

    respond_to do |format|
      if @document.save
        SlackService.new.new_document(@document).deliver
        if params[:document_type] == 'invoice'
          @template = Template.where(company: @company).where('slug LIKE ?', 'payable-invoices%').take
          @workflow = Workflow.new(user: current_user, company: @company, template: @template, identifier: @document.identifier)
          @workflow.template_data(@template)
          @workflow.save
          @document.update_attributes(workflow: @workflow)
        end

        format.html { redirect_to @workflow.nil? ? symphony_documents_path : symphony_workflow_path(@workflow.template.slug, @workflow.identifier), notice: 'Document was successfully created.' }
        format.json { render :show, status: :created, location: @document}
      else
        set_templates

        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @document.update(document_params)
      redirect_to symphony_document_path, notice: 'Document was successfully updated.'
    else
      set_templates
      render :edit
    end
  end

  def destroy
    @document.destroy
    redirect_to symphony_documents_path, notice: 'Document was successfully destroyed.'
  end

  def upload_invoice
    set_company_workflows
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
    @workflows = @company.workflows
  end

  def set_workflow
    @workflow = @workflows.find_by(identifier: params[:workflow]) if params[:workflow].present?
  end
end