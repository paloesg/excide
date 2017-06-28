class WorkflowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workflow

  def show
    # Look for existing workflow if not create new workflow
    @workflow = @workflows.create_with(user: @user).find_or_create_by(template: @template, company: @company)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_workflow
    @user = current_user
    @company = @user.company
    @workflows = @company.workflows
    @template = Template.find(params[:workflow_name])
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed)
  end
end
