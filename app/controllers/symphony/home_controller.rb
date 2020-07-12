class Symphony::HomeController < ApplicationController
  before_action :authenticate_user!, except: [:terms, :privacy]

  def index
    @templates = policy_scope(Template).assigned_templates(current_user)
    @template_pro = @templates.joins(sections: :tasks).where(tasks: {task_type: ["create_invoice_payable", "xero_send_invoice", "create_invoice_receivable", "coding_invoice"]})

    @workflows_array = policy_scope(Workflow).includes(:template).where(template: @templates).where(completed: [false, nil]).where.not(deadline: nil)
    workflows_sort = @workflows_array.sort_by(&:deadline)
    params[:direction] == "desc" ? workflows_sort.reverse! : workflows_sort
    if params[:workflow_type].blank?
      templates_type = workflows_sort
    else
      templates_type = workflows_sort.select{ |t| t.template.slug == params[:workflow_type] }
    end
    @workflows = workflows_sort.uniq(&:template).first(5)

    @outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where.not(completed: true).where.not(deadline: nil).where(company: current_user.company).order(:deadline).includes(:task)

    @batch_count = policy_scope(Batch).count
    @reminder_count = current_user.reminders.where(company: current_user.company).count
    @recurring_count = current_user.company.recurring_workflows.all.count
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end

  private

  def sort_column(array)
    array.sort_by{
      |item| if params[:sort] == "template" then item.template.title.upcase
      elsif params[:sort] == "completed" then item.completed ? 'Completed' : item.current_section&.section_name
      end
    }
  end
end
