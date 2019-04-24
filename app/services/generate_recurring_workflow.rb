class GenerateRecurringWorkflow

  def initialize(recurring_workflow)
    @recurring_workflow = recurring_workflow
  end

  def run
    get_recurring_workflow_today
    @current_recurring_workflows.each do |workflow|
      @next_workflow = Workflow.create(user_id: workflow.user.id, company_id: workflow.company.id, template_id: workflow.template.id, recurring_workflow_id: @recurring_workflow.id, identifier: (Date.current.to_s + '-' + workflow.template.title + '-' + SecureRandom.hex).parameterize.upcase)
      set_next_recurring_workflow
    end
  end

  private
  def get_recurring_workflow_today
    @current_recurring_workflows = Workflow.today.where(recurring_workflow_id: @recurring_workflow.id)
  end

  def set_next_recurring_workflow
    @recurring_workflow.next_workflow_date = Date.current + @recurring_workflow.freq_value.send(@recurring_workflow.freq_unit)
    @recurring_workflow.save   
  end
end