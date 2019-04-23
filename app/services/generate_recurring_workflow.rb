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
    case @recurring_workflow.freq_unit
    when 'days'
      @next_workflow.next_workflow_date = Date.current + @next_workflow.recurring_workflow.freq_value.days
    when 'weeks'
      @next_workflow.next_workflow_date = Date.current + @next_workflow.recurring_workflow.freq_value.weeks
    when 'months'
      @next_workflow.next_workflow_date = Date.current + @next_workflow.recurring_workflow.freq_value.months
    when 'years'
      @next_workflow.next_workflow_date = Date.current + @next_workflow.recurring_workflow.freq_value.years
    end
    @next_workflow.save   
  end
end