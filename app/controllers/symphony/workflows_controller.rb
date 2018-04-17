class Symphony::WorkflowsController < WorkflowsController
  before_action :set_clients, only: [:new, :create, :edit, :update]
  before_action :set_workflow, only: [:show, :edit, :update, :destroy, :assign, :section, :reset]

  def new
    @workflow = Workflow.new
    @workflow.template_data(@template)
  end

  def create
    @workflow = Workflow.new(workflow_params)
    @workflow.user = @user
    @workflow.company = @company
    @workflow.template = @template
    @workflow.workflowable = Client.create(name: params[:workflow][:client][:name], identifier: params[:workflow][:client][:identifier], company: @company) unless params[:workflow][:workflowable_id].present?
    if @workflow.save
      if params[:assign]
        redirect_to assign_symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully created.'
      else
        redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully created.'
      end
    else
      render :new
    end
  end

  def show
    @workflow = @workflows.find_by(identifier: params[:workflow_identifier])
    @sections = @template.sections
    @section = @workflow.current_section
    @activities = PublicActivity::Activity.where(recipient_type: "Workflow", recipient_id: @workflow.id).order("created_at desc")

    set_tasks
    set_documents
  end

  def edit
  end

  def update
    @workflow.workflowable = Client.create(name: params[:workflow][:client][:name], identifier: params[:workflow][:client][:identifier], company: @company) unless params[:workflow][:workflowable_id].present?

    if @workflow.update(workflow_params)
      if params[:assign]
        redirect_to assign_symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully edited.'
      else
        redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully edited.'
      end
    else
      render :edit
    end
  end

  def section
    @workflow = @workflows.find_by(identifier: params[:workflow_identifier])
    @sections = @template.sections
    @section = @sections.find(params[:section_id])

    set_tasks
    set_documents
    render :show
  end

  def assign
    @workflow = @workflows.find_by(identifier: params[:workflow_identifier])
    @sections = @template.sections
  end

  def approve
    @action = Task.find_by_id(params[:task_id]).get_company_action(@company, params[:workflow_identifier])

    respond_to do |format|
      if @action.update_attributes(approved_by: current_user.id)
        format.json { render json: @action.completed, status: :ok }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  def reset
    @company_actions = @company.company_actions.where(workflow_id: @workflow.id)
    @workflow.update_attribute(:completed, false)
    @company_actions.update_all(completed: false, completed_user_id: nil)
    redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully reset.'
  end

  private

  def set_company_and_roles
    @user = current_user
    @company = @user.company
    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
  end

  def set_workflow
    @workflows = @company.workflows
    @workflow = @workflows.find_by(identifier: params[:workflow_identifier])
    @documents = @company.documents.order(created_at: :desc)
    @document_templates = DocumentTemplate.where(template: @workflow.template)
  end

  def set_clients
    @clients = Client.where(company: @company)
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed, :deadline, :identifier, :workflowable_id, :workflowable_type, :workflowable, :remarks, data_attributes: [:name, :value, :_destroy])
  end

  def set_documents
    @documents = @company.documents.where(workflow_id: @workflow.id).order(created_at: :desc)
  end
end