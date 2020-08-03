class WorkflowActionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workflow_action

  def update
    respond_to do |format|
      if @workflow_action.update(workflow_action_params)
        format.json { render json: @workflow_action, status: :ok }
        #update workflow total time
        workflow = @workflow_action.workflow
        workflow.total_time = workflow.workflow_actions.sum(:time_spent_mins)
        workflow.save
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
    params.require(:workflow_action).permit(:assigned_user_id, :remarks, :time_spent_mins)
  end
end
