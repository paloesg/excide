class Symphony::TemplatesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_template, except: [:index, :new, :create, :clone]
  before_action :find_roles, only: [:new, :edit, :update, :create_section]

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Template
    @templates = policy_scope(Template)
  end

  def new
    @template = Template.new
    authorize @template
    @general_templates = Template.where(company: nil)
  end

  def create
    if params[:template][:clone]
      @template = Template.find(params[:template][:clone]).deep_clone include: { sections: :tasks }
      @template.title = template_params[:title]
    else
      @template = Template.new(template_params)
    end
    authorize @template
    @template.company = @company
    if @template.save
      redirect_to edit_symphony_template_path(@template)
    else
      render :new
    end
  end

  def edit
    authorize @template
  end

  def update
    authorize @template
    if @template.update(template_params)
      redirect_to edit_symphony_template_path(@template)
    else
      render :edit
    end
  end

  def create_section
    authorize @template
    @section = Section.create(section_name: params[:new_section], template_id: @template.id, position: params[:position])
    respond_to do |format|
      if @section.save
        format.html { redirect_to edit_symphony_template_path(@template), notice: 'Section was successfully created.' }
        format.js { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.html { redirect_to edit_symphony_template_path(@template) , alert: @section.errors.full_messages.join(" and ") } if @section.errors.messages[:section_name].present? and @section.errors.messages[:position].present?
        format.html { redirect_to edit_symphony_template_path(@template) , alert: @section.errors.full_messages.join } if @section.errors.messages[:section_name].present?
        format.html { redirect_to edit_symphony_template_path(@template) , alert: @section.errors.full_messages.join } if @section.errors.messages[:position].present?
        format.js { render js: 'Turbolinks.visit(location.toString());' }
      end
    end
  end

  def destroy_section
    authorize @template
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
