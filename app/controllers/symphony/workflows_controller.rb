class Symphony::WorkflowsController < WorkflowsController
  before_action :set_clients, only: [:new, :create, :edit, :update]
  before_action :set_workflow, only: [:show, :edit, :update, :destroy, :assign, :section, :reset]
  before_action :set_attributes_metadata, only: [:create, :update]

  def new
    @workflow = Workflow.new
    @workflow.template_data(@template)
  end

  def create
    @workflow = Workflow.new(workflow_params)
    @workflow.user = current_user
    @workflow.company = @company
    @workflow.template = @template

    @workflow.workflowable = Client.create(name: params[:workflow][:client][:name], identifier: params[:workflow][:client][:identifier], company: @company, user: current_user) unless params[:workflow][:workflowable_id].present?

    if @workflow.save
      log_activity
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
    @section = params[:section_id] ? @sections.find(params[:section_id]) : @workflow.current_section
    @activities = PublicActivity::Activity.where(recipient_type: "Workflow", recipient_id: @workflow.id).order("created_at desc")

    set_tasks
    set_documents
  end

  def edit
  end

  def update
    @workflow.workflowable = Client.create(name: params[:workflow][:client][:name], identifier: params[:workflow][:client][:identifier], company: @company) unless params[:workflow][:workflowable_id].present?

    if @workflow.update(workflow_params)
      log_activity
      if params[:assign]
        redirect_to assign_symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully edited.'
      else
        redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully edited.'
      end
    else
      render :edit
    end
  end

  def assign
    @workflow = @workflows.find_by(identifier: params[:workflow_identifier])
    @sections = @template.sections
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

  def set_attributes_metadata
    params[:workflow][:data_attributes].to_a.each do |key, value|
      if value[:_create] == '1' or value[:_update] == '1' or value[:_destroy] == '1'
        value[:user_id] = @user.id
        value[:updated_at] = Time.current
      end
    end
  end

  def log_activity
    params[:workflow][:data_attributes].to_a.each do |key, value|
      if value[:_create] == '1'
        @workflow.create_activity key: 'workflow.create_attribute', owner: User.find_by(id: value[:user_id]), params: { attribute: {name: value[:name], value: value[:value]} }
      elsif value[:_update] == '1'
        @workflow.create_activity key: 'workflow.update_attribute', owner: User.find_by(id: value[:user_id]), params: { attribute: {name: value[:name], value: value[:value]} }
      elsif value[:_destroy] == '1'
        @workflow.create_activity key: 'workflow.destroy_attribute', owner: User.find_by(id: value[:user_id]), params: { attribute: {name: value[:name], value: value[:value]} }
      end
    end
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed, :deadline, :identifier, :workflowable_id, :workflowable_type, :workflowable, :remarks, data_attributes: [:name, :value, :user_id, :updated_at, :_create, :_update, :_destroy])
  end

  def set_documents
    @documents = @company.documents.where(workflow_id: @workflow.id).order(created_at: :desc)
  end
end