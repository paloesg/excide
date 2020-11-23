class Motif::TemplatesController < ApplicationController
  layout 'motif/application'
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_template, except: [:index, :new, :create]

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Template
    # If template_type is nil, it means it is from Symphony
    @templates = policy_scope(Template).where.not(template_type: nil)
  end

  def new
    @template = Template.new
    authorize @template
    section = @template.sections.build
    # Pass in role in NEW and EDIT template form to pass validation
    @role = Role.find_by(name: "franchisee_owner", resource: current_user.company)
  end

  def create
    @template = Template.new(template_params)
    authorize @template
    @template.company = @company
    if @template.save
      redirect_to edit_motif_template_path(@template), notice: "Template has been successfully saved!"
    else
      flash[:alert] = @template.errors.full_messages.join
      render :new
    end
  end

  def edit
    authorize @template
    # Pass in role in NEW and EDIT template form to pass validation
    @role = Role.find_by(name: "franchisee_owner", resource: current_user.company)
    @documents = policy_scope(Document).order(created_at: :desc)
  end

  def update
    authorize @template
    if @template.update(template_params)
      redirect_to edit_motif_template_path(@template), notice: "Template has been successfully updated!"
    else
      flash[:alert] = @template.errors.full_messages.join
      render :edit
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

  private
  def set_template
    @template = Template.includes(sections: [tasks: [:role, :user, :document_template]]).find(params[:template_slug])
  end

  def set_company
    @company = current_user.company
  end

  def template_params
    params.require(:template).permit(:title, :company_id, :workflow_type, :template_type, :deadline_day, :deadline_type, :template_pattern, :start_date, :end_date, :freq_value, :freq_unit, :next_workflow_date, sections_attributes: [:id, :section_name, :position, tasks_attributes: [:id, :child_workflow_template_id, :position, :task_type, :instructions, :role_id, :user_id, :document_template_id, :survey_template_id, :deadline_day, :deadline_type, :set_reminder, :important, :link_url, :image_url, :description, :_destroy] ])
  end
end
