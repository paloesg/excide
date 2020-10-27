class Symphony::TemplatesController < ApplicationController
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
          if task.user
            user = User.find_by(first_name: task.user.first_name, company: @company.id)
            user = User.create(first_name: task.user.first_name, company: @company.id) if user.blank?
            task.user = user
          end
        end
      end
      @template.title = template_params[:title]
      @template.workflow_type = template_params[:workflow_type]
      @template.deadline_day = template_params[:deadline_day]
      @template.deadline_type = template_params[:deadline_type]
      @template.template_pattern = template_params[:template_pattern]
      @template.start_date = template_params[:start_date]
      @template.end_date = template_params[:end_date]
      @template.freq_value = template_params[:freq_value]
      @template.freq_unit = template_params[:freq_unit]
    else
      @template = Template.new(template_params)
    end
    authorize @template
    @template.company = @company
    if @template.save
      # Do not create a new empty section when cloning template
      unless params[:template][:clone]
        # Instead of removing section model completely, create a default section that links template with task, but don't show in the UI
        @section = Section.create(position: 1, template_id: @template.id)
      end
      redirect_to edit_symphony_template_path(@template, last_action: 'create')
    else
      # Validation error will render the new page due to not being saved. The clone template would return an error because it couldnt find @general_templates and @templates. Hence the variables are inserted here
      @general_templates = Template.where(company: nil)
      @templates = policy_scope(Template).assigned_templates(current_user)
      flash[:alert] = @template.errors.full_messages.join
      render :new
    end
  end

  def edit
    authorize @template
    @templates = policy_scope(Template).assigned_templates(current_user)
  end

  def update
    authorize @template
    if params[:template].present?
      if @template.update(template_params)
        if params[:last_action].present?
          # params[:last_action] checks that last action comes from template create method, then set recurring attributes to template and create the first workflow
          @workflow = Workflow.create(user: current_user, company: current_user.company, template: @template, created_at: @template.start_date)
          # Set initial recurring attributes
          @template.set_recurring_attributes
          # Set the 1st next_workflow_date after workflow is created
          @template.set_next_workflow_date(@workflow)
          redirect_to symphony_workflows_path(workflow_name: @template.slug)
        else
          flash[:notice] = 'Template has been saved.'
          redirect_to edit_symphony_template_path(@template)
        end
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
      respond_to do |format|
        format.html { redirect_to symphony_templates_path }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Routine was successfully deleted.'
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
    @template = Template.includes(sections: [tasks: [:role, :user, :document_template]]).find(params[:template_slug])
  end

  def find_roles
    @roles = Role.where(resource: @company)
  end

  def find_users
    @users = User.where(company_id: @company.id)
  end

  def template_params
    params.require(:template).permit(:title, :company_id, :workflow_type, :deadline_day, :deadline_type, :template_pattern, :start_date, :end_date, :freq_value, :freq_unit, :next_workflow_date, sections_attributes: [:id, :section_name, :position, tasks_attributes: [:id, :child_workflow_template_id, :position, :task_type, :instructions, :role_id, :user_id, :document_template_id, :survey_template_id, :deadline_day, :deadline_type, :set_reminder, :important, :link_url, :image_url, :description, :_destroy] ])
  end
end
