class Symphony::HomeController < ApplicationController
  layout 'symphony/application'

  before_action :authenticate_user!, except: [:terms, :privacy]

  def index
    @templates = policy_scope(Template).assigned_templates(current_user)
    @template_pro = @templates.joins(sections: :tasks).where(tasks: {task_type: ["create_invoice_payable", "xero_send_invoice", "create_invoice_receivable", "coding_invoice"]})

    @workflows_array = policy_scope(Workflow).includes(:template).where(template: @templates).where(completed: [false, nil]).where.not(deadline: nil)
    workflows_sort = @workflows_array.sort_by(&:deadline)
    @workflows = workflows_sort.uniq(&:template).first(5)

    @outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where.not(completed: true).where.not(deadline: nil).where(company: current_user.company).order(:deadline).includes(:task).first(3)
  end

  def add_tasks_to_timesheet
    params[:tasks].each do |task_id|
      @event_type = EventType.find_or_create_by(name: Task.find(task_id.to_i).instructions)
      @event = Event.create(event_type: @event_type, company_id: current_user.company.id, start_time: DateTime.current, end_time: DateTime.current + 1.hour)
      @generated_allocation = GenerateTimesheetAllocationService.new(@event, current_user).run
    end
    redirect_to conductor_events_path, notice: "Timesheet has been added!"
  end

  private

  def sort_column(array)
    array.sort_by{
      |item| item.deadline ? item.deadline : Time.at(0)
    }
  end
end
