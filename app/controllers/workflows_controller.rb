class WorkflowsController < ApplicationController
  layout "dashboard/application"

  before_action :authenticate_user!
  before_action :set_workflow

  def show
    # Look for existing workflow if not create new workflow and then show the tasks from the first section
    #TODO: Refactor to separate workflow creation
    @workflow = @workflows.create_with(user: @user).find_or_create_by(template: @template, company: @company)
    @sections = @template.sections
    @section = @workflow.current_section

    set_tasks
  end

  def section
    @workflow = @workflows.where(template: @template).first
    @sections = @template.sections
    @section = @sections.find(params[:section_id])

    set_tasks
    render :show
  end

  def toggle
    @action = Task.find_by_id(params[:task_id]).get_company_action(@company.id, params[:workflow_identifier])

    respond_to do |format|
      if @action.update_attributes(completed: !@action.completed)
        format.json { render json: @action.completed, status: :ok }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_workflow
    @user = current_user

    if current_user.has_role? :admin
      @companies = Company.all
      @company = Company.friendly.find(params[:company_name])
    elsif params[:company_name].present?
      @company = @user.company
      redirect_to dashboard_path
    else
      @company = @user.company
    end

    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
    @workflows = @company.workflows
    @template = Template.find(params[:workflow_name])
    @documents = @company.documents.order(created_at: :desc)
  end

  def set_tasks
    @next_section = @workflow.next_section
    @tasks = @section&.tasks
    @current_task = @workflow.current_task
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed, :deadline, :identifier)
  end
end
