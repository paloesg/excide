class WorkflowsController < ApplicationController
  layout "dashboard/application"

  before_action :authenticate_user!
  before_action :set_workflow

  def show
    # Look for existing workflow if not create new workflow and then show the tasks from the first section
    @workflow = @workflows.create_with(user: @user).find_or_create_by(template: @template, company: @company)
    @sections = @template.sections
    @current_section = @sections.joins(tasks: :company_actions).where(company_actions: {completed: false}).to_ary.shift

    set_tasks
  end

  def section
    @workflow = @workflows.where(template: @template).first
    @sections = @template.sections
    @current_section = @sections.find(params[:section_id])

    set_tasks
    render :show
  end

  def toggle
    @action = Task.find_by_id(params[:task_id]).get_company_action(@company)

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
      @company = Company.find(params[:company_id])
    elsif params[:company_id].present?
      @company = @user.company
      redirect_to dashboard_path
    else
      @company = @user.company
    end

    @workflows = @company.workflows
    @template = Template.find(params[:workflow_name])
  end

  def set_tasks
    @next_section = @sections.find_by_id(@current_section.id + 1)
    @tasks = @current_section.tasks
    @current_task = @tasks.first
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed)
  end
end
