class Symphony::HomeController < ApplicationController
  layout 'metronic/application'

  before_action :authenticate_user!

  def index
    @templates = policy_scope(Template).assigned_templates(current_user)
    @template_pro = @templates.joins(sections: :tasks).where(tasks: {task_type: ["create_invoice_payable", "xero_send_invoice", "create_invoice_receivable", "coding_invoice"]})
    @workflow_count = policy_scope(Workflow).where(template: @templates).count
    @outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where.not(completed: true).where.not(deadline: nil).where(company: @company).order(:deadline).includes(:task).count
    @batch_count = policy_scope(Batch).count
    @reminder_count = current_user.reminders.where(company: current_user.company).count
    @recurring_count = current_user.company.recurring_workflows.all.count
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end
end
