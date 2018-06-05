class Symphony::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!

  def index
    @company = current_user.company
    @templates = Template.assigned_templates(current_user)

    @workflows_array = @templates.map(&:current_workflows).flatten
    @workflows_sort = sort_column(@workflows_array)
    params[:direction] == "desc" ? @workflows_sort.reverse! : @workflows_sort
    @workflows = Kaminari.paginate_array(@workflows_sort).page(params[:page]).per(10)

    @outstanding_actions = WorkflowAction.all_user_actions(current_user).where.not(completed: true).where.not(deadline: nil).order(:deadline)
  end

  def search
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
