class Symphony::WorkflowActionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workflow_action
  before_action :require_symphony

  def update
    respond_to do |format|
      if @workflow_action.update(workflow_action_params)
        format.json { render json: @workflow_action, status: :ok }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # checks if the user's company has Symphony. Links to symphony_policy.rb
  def require_symphony
    authorize :symphony, :index?
  end

  def set_workflow_action
    @workflow_action = WorkflowAction.find(params[:id])
  end

  def workflow_action_params
    params.require(:workflow_action).permit(:assigned_user_id, :remarks, :time_spent_mins)
  end
end
