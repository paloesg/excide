class Motif::WorkflowsController < ApplicationController
  layout 'motif/application'
  before_action :set_company
  before_action :set_workflow, only: [:show, :update]

  def index
    # Select templates in that company and with the right template_type. params[:template_type] is passed through url params in the sidebar
    @templates = Template.includes(:company).where(company_id: @company.id, template_type: params[:template_type])
    # If current user is a franchisee, it can only see it's own workflow
    @workflows = current_user.has_role?(:franchisee_owner, current_user.company) ? current_user.outlet.workflows.includes(:template).where(templates: {template_type: params[:template_type]}) : Workflow.includes(:template).where(templates: { company_id: @company.id, template_type: params[:template_type] })
    @outlets = Outlet.includes(:franchisee).where(franchisees: { company_id: @company.id })
    @workflow = Workflow.new
  end

  def show
  end

  def create
    @workflow = Workflow.new(workflow_params)
    @workflow.user = @user
    @workflow.company = @company
    respond_to do |format|
      if @workflow.save
        format.html { redirect_to motif_workflows_path, notice: 'Workflow was successfully created.' }
        format.json { render :show, status: :created, location: @workflow }
      else
        format.html { render :new }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    @wfa = @workflow.workflow_actions.find(params[:workflow_action_id])
    @wfa.links = { links: [] }
    params[:links].each do |link|
      @wfa.links["links"] << link
    end
    respond_to do |format|
      if @wfa.save
        format.html { redirect_to motif_outlet_workflow_path(outlet_id: @wfa.workflow.outlet.id, id: @wfa.workflow.id) , notice: 'Workflow was successfully created.' }
        format.json { render :show, status: :created, location: @wfa }
      else
        format.html { render :new }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    @action = Task.find_by_id(params[:task_id]).get_workflow_action(@company.id, params[:workflow_id])
    @workflow = Workflow.find(params[:workflow_id])
    authorize @workflow
    respond_to do |format|
      if @action.update_attributes(completed: !@action.completed, completed_user_id: current_user.id, current_action: false)
        format.json { render json: @action.completed, status: :ok }
        flash[:notice] = "You have successfully completed all outstanding items for your current task." if @action.all_actions_task_group_completed?
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end

  def set_workflow
    @workflow = Workflow.find(params[:id])
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :outlet_id, :completed, :deadline, :workflowable_id, :workflowable_type, :remarks, workflowable_attributes: [:id, :name, :identifier, :user_id, :company_id, :xero_email], data_attributes: [:name, :value, :user_id, :updated_at, :_create, :_update, :_destroy])
  end
end
