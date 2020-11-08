class Motif::WorkflowsController < ApplicationController
  layout 'motif/application'
  before_action :set_company

  def index
    @outlets = Outlet.includes(:franchisee).where(franchisees: { company_id: @company.id })
    @workflow = Workflow.new
  end

  def show
  end

  def create
    
  end

  def edit
  end

  private

  def set_company
    @company = current_user.company
  end

  def workflow_params
    params.require(:workflow).permit(:user_id, :company_id, :template_id, :completed, :deadline, :workflowable_id, :workflowable_type, :remarks, workflowable_attributes: [:id, :name, :identifier, :user_id, :company_id, :xero_email], data_attributes: [:name, :value, :user_id, :updated_at, :_create, :_update, :_destroy])
  end
end
