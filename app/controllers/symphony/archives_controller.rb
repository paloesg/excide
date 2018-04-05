class Symphony::ArchivesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!

  def index
  end

  private

  def set_workflow
    @user = current_user
    @company = @user.company
    @templates = view_context.get_relevant_templates
    @workflows_array = @templates.map(&:workflows).flatten

    if params[:workflow_type].blank?
      @templates_type = @workflows_array
    else
      @templates_type = @workflows_array.select{ |t| t.template.slug == params[:workflow_type] }
    end

    @templates_completed = @workflows_array.map{ |w| w.template }.uniq
    @workflows_completed = @templates_type.select{ |w| w.completed? }
    @workflows_sort = sort_column(@workflows_completed)
    params[:direction] == "desc" ? @workflows_sort.reverse! : @workflows_sort
    @workflows = Kaminari.paginate_array(@workflows_sort).page(params[:page]).per(10)
  end

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
