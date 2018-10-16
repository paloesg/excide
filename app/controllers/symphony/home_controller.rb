class Symphony::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!

  def index
    @company = current_user.company
    @templates = Template.assigned_templates(current_user)
    @clients = @company.clients

    @workflows_array = @templates.map(&:current_workflows).flatten
    @workflows_sort = sort_column(@workflows_array)
    params[:direction] == "desc" ? @workflows_sort.reverse! : @workflows_sort

    if params[:workflow_type].blank?
      @templates_type = @workflows_sort
    else
      @templates_type = @workflows_sort.select{ |t| t.template.slug == params[:workflow_type] }
    end

    @workflows = Kaminari.paginate_array(@templates_type).page(params[:page]).per(10)
    @outstanding_actions = WorkflowAction.all_user_actions(current_user).where.not(completed: true).where.not(deadline: nil).order(:deadline)

    @reminder_count = current_user.reminders.count

    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end

  def search
    # TODO: Generate secured api key per user tag, only relevant users are tagged to each workflow.
    @public_key = Algolia.generate_secured_api_key(ENV['ALGOLIASEARCH_API_KEY_SEARCH'], {filters: 'company.slug:' + current_user.company.slug})
  end

  private

  def sort_column(array)
    array.sort_by{
      |item| if params[:sort] == "template" then item.template.title.upcase
      elsif params[:sort] == "remarks" then item.remarks ? item.remarks.upcase : ""
      elsif params[:sort] == "deadline" then item.deadline ? item.deadline : Time.at(0)
      elsif params[:sort] == "workflowable" then item.workflowable ? item.workflowable&.name.upcase : ""
      elsif params[:sort] == "completed" then item.completed ? 'Completed' : item.current_section&.display_name
      elsif params[:sort] == "identifier" then item.identifier ? item.identifier.upcase : ""
      end
    }
  end

end
