class Symphony::RecurringWorkflowsController < ApplicationController
  layout "dashboard/application"
  
  before_action :authenticate_user!
  before_action :set_company

  def new
    @recurring_workflow = RecurringWorkflow.new
  end

  def create
    @recurring_workflow = RecurringWorkflow.new(recurring_workflow_params)
    @recurring_workflow.template = Template.find_by(slug: params[:recurring_workflow_name])
    @recurring_workflow.recurring = true
    if @recurring_workflow.save
      #creating the first workflow before recurring it through calling the service object
      @workflow = Workflow.create(user_id: current_user.id, company_id: @company.id, template_id: @recurring_workflow.template.id, identifier: (Date.current.to_s + '-' + @recurring_workflow.template.title + '-' +SecureRandom.hex).parameterize.upcase)
      #a case statement to store the first next_workflow_date when workflow is being created through the recurring_workflow form.
      case @recurring_workflow.freq_unit
      when 'days'  
        @workflow.next_workflow_date = Date.current + @recurring_workflow.freq_value.days
      when 'weeks'  
        @workflow.next_workflow_date = Date.current + @recurring_workflow.freq_value.weeks
      when 'months'  
        @workflow.next_workflow_date = Date.current + @recurring_workflow.freq_value.months
      when 'years'  
        @workflow.next_workflow_date = Date.current + @recurring_workflow.freq_value.years
      end
      @workflow.recurring_workflow = @recurring_workflow
      @workflow.save
      redirect_to symphony_workflow_path(@recurring_workflow.template.slug, @workflow.identifier), notice: 'Workflow was successfully created.'
    end
  end

  private
  def recurring_workflow_params
    params.require(:recurring_workflow).permit(:recurring, :freq_value, :freq_unit, :template_id, :next_workflow_date)
  end

  def set_company
    @company = current_user.company
  end
end
