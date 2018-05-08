class Symphony::DocumentsController < DocumentsController
  before_action :set_templates, only: [:index, :new, :edit]
  before_action :set_company_workflows, only: [:index, :new, :edit]
  before_action :set_workflow, only: [:new, :edit]

  def index
    @documents = []

    # For each workflow that a company has, retrieve all the documents present, ordered by document templates so that they can be displayed in the table
    @workflows.each do |workflow|
      docs = []
      # First element of array contains the workflow so that workflow info can be retrieved for building the table
      docs << workflow
      @document_templates.each do |template|
        # Rest of the elements are documents that belong to the particular workflow, ordered by the document template
        docs << Document.find_by(company: @company, workflow: workflow, document_template: template)
      end
      @documents << docs
    end
  end

  def create
    @document = Document.new(document_params)
    @document.company = @company
    @document.user = @user

    @workflow = Workflow.find_by(identifier: params[:workflow]) if params[:workflow].present?

    if @document.save
      SlackService.new.new_document(@document).deliver
      redirect_to @workflow.nil? ? symphony_documents_path : symphony_workflow_path(@workflow.template.slug, @workflow.identifier), notice: 'Document was successfully created.'
    else
      render :new
    end
  end

  def update
    if @document.update(document_params)
      redirect_to symphony_documents_path, notice: 'Document was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
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

  def set_workflow
    @workflow = @workflows.find_by(identifier: params[:workflow]) if params[:workflow].present?
  end
end