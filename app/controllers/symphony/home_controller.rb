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
      @outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where.not(completed: true).where(company: current_user.company).includes(:task)
    elsif params[:tasks] == "All tasks"
      @outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where(company: current_user.company).includes(:task)
    else
      @outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where(completed: true).where(company: current_user.company).includes(:task)
    end
    if params[:created_at].blank? || params[:created_at] == "Last 7 days"
      @outstanding_actions = @outstanding_actions.where('created_at >= ?', Time.zone.now - 7.days)
    elsif params[:created_at] == "Last 30 days"
      @outstanding_actions = @outstanding_actions.where('created_at >= ?', Time.zone.now - 30.days)
    end
    if params[:types] == "Tasks related to Routine"
      @outstanding_actions = @outstanding_actions.select {|action| action.workflow_id.present?}
    elsif params[:types] == "Adhoc tasks"
      @outstanding_actions = @outstanding_actions.select {|action| action.workflow_id.nil?}
    end
    @actions_sort = sort_column(@outstanding_actions).reverse!
    params[:direction] == "desc" ? @actions_sort.reverse! : @actions_sort
  end

  private

  def sort_column(array)
    array.sort_by{
      |item| item.deadline ? item.deadline : Time.at(0)
    }
  end
end
