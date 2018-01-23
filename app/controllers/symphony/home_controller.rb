class Symphony::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_workflow, only: [:show]

  def show
  end

  private

  def set_workflow
    @user = current_user
    @company = @user.company
    @templates = @company.templates
    @workflows_array = @templates.map(&:workflows).flatten
    @workflows_sort = sort_column(@workflows_array)
    params[:direction] == "desc" ? @workflows_sort.reverse! : @workflows_sort
    @workflows = Kaminari.paginate_array(@workflows_sort).page(params[:page]).per(10)
  end

  private def sort_column(array)
    array.sort_by{
      |item| if params[:sort] == "template" then item.template.title 
      elsif params[:sort] == "workflowable" then item.workflowable ? item.workflowable&.name : ""
      elsif params[:sort] == "completed" then item.completed ? 'Completed' : item.current_section&.display_name
      else item[params[:sort]] end 
    }
  end

end
