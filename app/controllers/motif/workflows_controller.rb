class Motif::WorkflowsController < ApplicationController
  layout 'motif/application'
  before_action :set_company

  def index
    # Select templates related to that franchise company only
    @templates = Template.includes(:company).where(company_id: @company.id)
    @workflows = Workflow.includes(:template).where(templates: { company_id: @company.id })
    @outlets = Outlet.includes(:franchisee).where(franchisees: { company_id: @company.id })
    @workflow = Workflow.new
  end

  def show
  end

  def create
    @workflow = Workflow.new(workflow_params)
    @workflow.user = @user
    @workflow.company = @company
    respond_to do |format|
      if @workflow.save
        format.html { redirect_to motif_workflows_path, notice: 'Workflow was successfully created.' }
        format.json { render :show, status: :created, location: @workflow }
      else
        format.html { render :new }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :outlet_id, :completed, :deadline, :workflowable_id, :workflowable_type, :remarks, workflowable_attributes: [:id, :name, :identifier, :user_id, :company_id, :xero_email], data_attributes: [:name, :value, :user_id, :updated_at, :_create, :_update, :_destroy])
  end
end
