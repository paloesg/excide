class Symphony::TemplatesController < ApplicationController
  # layout 'dashboard/application'
  layout 'metronic/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_template, except: [:index, :new, :create, :clone]
  before_action :find_roles, :find_users, only: [:new, :edit, :update]

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
    @templates = policy_scope(Template).assigned_templates(current_user)
  end

  def create
    if params[:template][:clone]
      @template = Template.find(params[:template][:clone]).deep_clone include: { sections: :tasks }
      @template.sections.each do |section|
        section.tasks.each do |task|
          if task.role
            # Get role of user company, if the role not exist, create the same role for current user company
            role = Role.find_by(name: task.role.name, resource_id: @company.id, resource_type: "Company")
            role = Role.create(name: task.role.name, resource_id: @company.id, resource_type: "Company") if role.blank?
            task.role = role
          end
        end
      end
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
    @templates = policy_scope(Template).assigned_templates(current_user)
  end

  def update
    authorize @template
    if params[:new_section_submit].present?
      @position = @template.sections.count + 1
      @section = Section.create(section_name: params[:new_section], template_id: @template.id, position: @position)
      if @section.save
        flash[:notice] = 'Section was successfully created.'
      else
        flash[:alert] = @section.errors.full_messages.join
      end
    end
    if params[:template].present?
      if @template.update(template_params)
        flash[:notice] = 'Template has been saved.'
        redirect_to edit_symphony_template_path(@template)
      else
        flash[:alert] = @template.errors.full_messages.join
        render :edit
      end
    else
      redirect_to edit_symphony_template_path(@template)
    end
  end

  def destroy
    authorize @template 
    if @template.destroy
      redirect_to symphony_templates_path, notice: 'Template was successfully deleted.'
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
    @template = Template.includes(sections: [tasks: [:role, :document_template]]).find(params[:template_slug])
  end

  def set_company
    @company = current_user.company
  end

  def find_roles
    @roles = Role.where(resource: @company)
  end

  def find_users
    @users = User.where(company_id: @company.id)
  end

  def template_params
    params.require(:template).permit(:title, :company_id, :workflow_type, sections_attributes: [:id, :section_name, :position, tasks_attributes: [:id, :child_workflow_template_id, :position, :task_type, :instructions, :role_id, :user_id, :document_template_id, :survey_template_id, :days_to_complete, :set_reminder, :important, :link_url, :image_url, :_destroy]])
  end
end
