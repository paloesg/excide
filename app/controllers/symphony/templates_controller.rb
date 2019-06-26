class Symphony::TemplatesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_template, except: [:index, :new, :create, :clone]
  before_action :find_roles, only: [:new, :edit, :update, :create_section]

  def index
    @templates = Template.all.where(company: @company)
  end

  def new
    @template = Template.new
    @general_templates = Template.where(company: nil)
  end

  def create
    if params[:template][:clone]
      @template = Template.find(params[:template][:clone]).deep_clone include: { sections: :tasks }
      @template.title = template_params[:title]
    else
      @template = Template.new(template_params)
    end
    @template.company = @company
    if @template.save
      redirect_to edit_symphony_template_path(@template)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @template.update(template_params)
      redirect_to edit_symphony_template_path(@template)
    else
      render :edit
    end
  end

  def create_section
    @position = @template.sections.count + 1
    @section = Section.create(section_name: params[:new_section], template_id: @template.id, position: @position)
    if @section.save
      redirect_to edit_symphony_template_path(@template)
    else
      render :edit
    end
  end

  def destroy_section
    @section = Section.find(params[:section_id])
    if @section.destroy
      redirect_to edit_symphony_template_path(@template.slug)
    else
      redirect_to symphony_templates_path
    end
  end

  private
  def set_template
    @template = Template.find(params[:template_slug])
  end

  def set_company
    @company = current_user.company
  end

  def find_roles
    @roles = Role.where(resource: @company)
  end

  def template_params
    params.require(:template).permit(:title, :company_id, :workflow_type, sections_attributes: [:id, :section_name, :position, tasks_attributes: [:id, :position, :task_type, :instructions, :role_id, :document_template_id, :days_to_complete, :set_reminder, :important, :link_url, :image_url, :_destroy] ])
  end
end
