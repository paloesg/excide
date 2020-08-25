class Symphony::HomeController < ApplicationController
  before_action :authenticate_user!, except: [:terms, :privacy]

  def index
    @templates = policy_scope(Template).assigned_templates(current_user)
    @template_pro = @templates.joins(sections: :tasks).where(tasks: {task_type: ["create_invoice_payable", "xero_send_invoice", "create_invoice_receivable", "coding_invoice"]})

    @workflows_array = policy_scope(Workflow).includes(:template).where(template: @templates).where(completed: [false, nil]).where.not(deadline: nil)
    workflows_sort = @workflows_array.sort_by(&:deadline)
    @workflows = workflows_sort.uniq(&:template).first(5)

    @outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where.not(completed: true).where.not(deadline: nil).where(company: current_user.company).order(:deadline).includes(:task).first(3)
  end

  def tasks
    if params[:tasks].blank? || params[:tasks] == "Only incomplete tasks"
      @get_outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where.not(completed: true).where(company: current_user.company).includes(:task)
    elsif params[:tasks] == "All tasks"
      @get_outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where(company: current_user.company).includes(:task)
    else
      @get_outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where(completed: true).where(company: current_user.company).includes(:task)
    end
    # Filtering by days
    @get_outstanding_actions = @get_outstanding_actions.where('created_at >= ?', Time.current - params[:created_at].to_i.days) unless params[:created_at].blank?
    # Actions that depends the type of task (with repetition task or adhoc)
    if params[:types] == "Tasks related to Routine"
      @get_outstanding_actions = @get_outstanding_actions.select {|action| action.workflow_id.present?}
    elsif params[:types] == "Adhoc tasks"
      @get_outstanding_actions = @get_outstanding_actions.select {|action| action.workflow_id.nil?}
    end
    @outstanding_actions = Kaminari.paginate_array(@get_outstanding_actions).page(params[:page]).per(10)
    @actions_sort = sort_column(@outstanding_actions).reverse!
    params[:direction] == "desc" ? @actions_sort.reverse! : @actions_sort
  end

  def activity_history
    if params[:created_at].present?
      @get_activities = PublicActivity::Activity.includes(:owner).where.not(recipient_type: "Event").where(owner_id: current_user.id).where('created_at >= ?', Time.current - params[:created_at].to_i.days).order("created_at desc")
    else
      # Get all current_user activities
      @get_activities = PublicActivity::Activity.includes(:owner).where.not(recipient_type: "Event").where(owner_id: current_user.id).order("created_at desc")
    end
    @activities = Kaminari.paginate_array(@get_activities).page(params[:page]).per(10)
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
