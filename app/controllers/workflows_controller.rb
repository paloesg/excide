class WorkflowsController < ApplicationController
  layout "dashboard/application"

  before_action :authenticate_user!
  before_action :set_company_and_roles
  before_action :set_template, except: [:toggle_all]
  before_action :set_workflow, only: [:show, :edit, :update, :destroy, :section]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def show
    # Look for existing workflow if not create new workflow and then show the tasks from the first section
    #TODO: Refactor to separate workflow creation
    @workflow = @workflows.create_with(user: @user).find_or_create_by!(template: @template, company: @company)
    @sections = @template.sections
    @section = @workflow.current_section
    @document_templates = DocumentTemplate.where(template: @workflow.template)

    set_tasks
  end

  def section
    @workflow = @workflows.where(template: @template).first
    @sections = @template.sections
    @section = @sections.find(params[:section_id])
    @document_templates = DocumentTemplate.where(template: @workflow.template)

    set_tasks
    render :show
  end

  def toggle
    @action = Task.find_by_id(params[:task_id]).get_workflow_action(@company.id, params[:workflow_id])
    @workflow = Workflow.find_by(id: params[:workflow_id] )
    authorize @workflow
    #manually saving updated_at of the batch to current time
    @workflow.batch.update(updated_at: Time.current) if @workflow.batch.present?
    respond_to do |format|
      if @action.update_attributes(completed: !@action.completed, completed_user_id: current_user.id)
        format.json { render json: @action.completed, status: :ok }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_all
    @actions = WorkflowAction.where(id: params[:workflow_action_ids])
    @workflow = @actions.last.workflow
    authorize @workflow
    #manually saving updated_at of the batch to current time
    @workflow.batch.update(updated_at: Time.current) if @workflow.batch.present?
    respond_to do |format|
      if @actions.update_all(completed: true, completed_user_id: current_user.id)
        format.json { render json: true, status: :ok }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.json { render json: @actions.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company_and_roles
    @user = current_user

    if current_user.has_role? :superadmin
      @companies = Company.all
      @company = Company.friendly.find(params[:company_name])
    elsif params[:company_name].present?
      @company = @user.company
      redirect_to dashboard_path
    else
      @company = @user.company
    end

    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
  end

  def set_template
    @template = Template.find(params[:workflow_name])
  end

  def set_workflow
    @workflows = @company.workflows
    @documents = @company.documents.order(created_at: :desc)
  end

  def set_tasks
    @next_section = @workflow.next_section
    @tasks = @section&.tasks.includes(:role)
    @current_task = @workflow.current_task
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed, :deadline)
  end
end
