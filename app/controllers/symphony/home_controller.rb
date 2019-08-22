class Symphony::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!

  def index
    @templates = policy_scope(Template).assigned_templates(current_user)
    @workflows_array = policy_scope(Workflow).includes(:template, :workflowable).where(template: @templates)
    @outstanding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where.not(completed: true).where.not(deadline: nil).where(company: @company).order(:deadline).includes(:task)
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end
end
