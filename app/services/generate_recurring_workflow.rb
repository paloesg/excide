class GenerateRecurringWorkflow

  def initialize(recurring_workflow)
    @recurring_workflow = recurring_workflow
  end

  def run
    @recurring_workflow.workflows.each do |workflow|
      Workflow.create(user_id: workflow.user.id, company_id: workflow.company.id, template_id: workflow.template.id, recurring_workflow_id: @recurring_workflow.id, identifier: (Date.current.to_s + '-' + workflow.template.title + '-' + SecureRandom.hex).parameterize.upcase)
    end
    set_next_recurring_workflow
  end

  private
  def set_next_recurring_workflow
    @recurring_workflow.next_workflow_date = Date.current + @recurring_workflow.freq_value.send(@recurring_workflow.freq_unit)
    @recurring_workflow.save   
  end
end