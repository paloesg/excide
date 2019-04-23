class Symphony::RecurringWorkflowsController < ApplicationController
  layout "dashboard/application"
  
  before_action :authenticate_user!
  before_action :set_template
  before_action :set_company

  def new
    @recurring_workflow = RecurringWorkflow.new
  end

  def create
    @recurring_workflow = RecurringWorkflow.new(recurring_workflow_params)
    @recurring_workflow.template = @template
    @recurring_workflow.recurring = true
    if @recurring_workflow.save
      #creating the first workflow before recurring it through calling the service object
      @workflow = Workflow.create(user_id: current_user.id, company_id: @company.id, template_id: @template.id, identifier: (Date.current.to_s + '-' + @template.title + '-' +SecureRandom.hex).parameterize.upcase)
      @workflow.recurring_workflow = @recurring_workflow
      @workflow.save
      redirect_to symphony_workflow_path(@template.slug, @workflow.identifier), notice: 'Workflow was successfully created.'
    end
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
