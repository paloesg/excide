class GenerateRecurringWorkflow

  def initialize(recurring_workflow)
    @recurring_workflow = recurring_workflow
  end

  def run
    generate_workflow
    set_next_recurring_workflow
  end

  private
  def generate_workflow
    Workflow.create(user_id: @recurring_workflow.user.id, company_id: @recurring_workflow.template.company.id, template_id: @recurring_workflow.template.id, recurring_workflow_id: @recurring_workflow.id, identifier: (Date.current.to_s + '-' + @recurring_workflow.template.title + '-' + SecureRandom.hex).parameterize.upcase, deadline: Date.current + 1.week)
  end

  def set_next_recurring_workflow
    @recurring_workflow.next_workflow_date = Date.current + @recurring_workflow.freq_value.send(@recurring_workflow.freq_unit)
    @recurring_workflow.save   
  end
end