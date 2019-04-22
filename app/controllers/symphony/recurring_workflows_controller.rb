class Symphony::RecurringWorkflowsController < ApplicationController
  layout "dashboard/application"
  
  before_action :authenticate_user!
  before_action :set_template
  before_action :set_company

  def new
    @recurring_workflow = RecurringWorkflow.new
  end

  def create

  end

  private
  def recurring_workflow_params
    params.require(:recurring_workflow).permit(:recurring, :freq_value, :freq_unit, :template_id)
  end

  def set_template
    @template = Template.find(params[:recurring_workflow_name])
  end

  def set_company
    @company = current_user.company
  end
end
