class WorkflowActionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workflow_action

  def update
    respond_to do |format|
      if @workflow_action.update_attributes(workflow_action_params)
        format.json { render json: @workflow_action, status: :ok }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_workflow_action
    @workflow_action = WorkflowAction.find(params[:id])
  end

  def workflow_action_params
    params.require(:workflow_action).permit(:assigned_user_id, :remarks)
  end
end
