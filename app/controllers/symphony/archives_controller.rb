class Symphony::ArchivesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!

  def index
    @user = current_user
    @company = @user.company
    @templates = Template.assigned_templates(current_user)
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

  def show
    @user = current_user
    @company = @user.company

    @template = @workflow[:archive]['template']
    @document_templates = DocumentTemplate.where(template: @workflow.template)
    @documents = @company.documents.where(workflow_id: @workflow.id).order(created_at: :desc)
    
    @workflows = @company.workflows
    @workflow = @workflows.find_by(identifier: params[:workflow_identifier])

    @sections = @workflow[:archive]['sections']
    @section = params[:section] ? @sections.select{|section| section['unique_name'] == params[:section]}.first : @workflow[:archive]['sections'].last
    @tasks = @section['tasks']
    @section_index = @sections.index(@section)

    @activities = PublicActivity::Activity.where(recipient_type: "Workflow", recipient_id: @workflow.id).order("created_at desc")
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
