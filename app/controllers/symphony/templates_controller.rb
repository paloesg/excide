class Symphony::TemplatesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_template_and_section, only: [:edit, :update]

  def index
    @templates = Template.all.where(company: @company)
  end

  def edit
    @roles = Role.all.where(resource: @company)
    @templates = Template.workflow_types
  end

  def update
    if @template.update!(template_params)
      redirect_to symphony_templates_path
    else
      render 'edit'
    end
  end

  private
  def set_template_and_section
    @template = Template.find(params[:template_slug])
    @section = Section.find(params[:section_id])
  end

  def set_company
    @company = current_user.company
  end

  def template_params
    params.require(:template).permit(:title, :company_id, :workflow_type, sections_attributes: [:id, :display_name, :unique_name, :position, tasks_attributes: [:id, :position, :task_type, :instructions, :role_id, :document_template_id, :days_to_complete, :set_reminder, :link_url, :image_url] ])
  end
end