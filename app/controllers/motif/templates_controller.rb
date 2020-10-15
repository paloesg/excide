class Motif::TemplatesController < ApplicationController
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
    @template = Template.new(template_params)
    authorize @template
    @template.company = @company
    if @template.save
      redirect_to edit_motif_template_path(@template, last_action: 'create')
    else
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
          redirect_to motif_workflows_path(workflow_name: @template.slug)
        else
          flash[:notice] = 'Template has been saved.'
          redirect_to edit_motif_template_path(@template)
        end
      else
        flash[:alert] = @template.errors.full_messages.join
        render :edit
      end
    else
      redirect_to edit_motif_template_path(@template)
    end
  end

  def destroy
    authorize @template
    if @template.destroy
      respond_to do |format|
        format.html { redirect_to motif_templates_path }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Routine was successfully deleted.'
    end
  end

  def destroy_section
    authorize @template
    @section = Section.find(params[:section_id])
    if @section.destroy
      redirect_to edit_motif_template_path(@template.slug)
    else
      redirect_to motif_templates_path
    end
  end

  private

  def set_template
    @template = Template.includes(sections: [tasks: [:role, :user, :document_template]]).find(params[:template_slug])
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
    params.require(:template).permit(:title, :company_id, :workflow_type, :deadline_day, :deadline_type, :template_pattern, :start_date, :end_date, :freq_value, :freq_unit, :next_workflow_date, sections_attributes: [:id, :section_name, :position, tasks_attributes: [:id, :child_workflow_template_id, :position, :task_type, :instructions, :role_id, :user_id, :document_template_id, :survey_template_id, :deadline_day, :deadline_type, :set_reminder, :important, :link_url, :image_url, :_destroy] ])
  end
end
