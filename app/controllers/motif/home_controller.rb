class Motif::HomeController < ApplicationController
  layout 'motif/application'
  
  before_action :set_company
  before_action :authenticate_user!

  def index
    @franchisees = Franchisee.includes(:company).where(company_id: @company.id)
    @outlets = @company.outlets
    # Get franchisees workflows
    @franchisees_workflows = current_user.active_outlet.workflows if current_user.has_role?(:franchisee_owner, @company) or current_user.has_role?(:franchisee_member, @company)
    # Find workflows that is not completed yet
    @onboarding_workflows = (current_user.has_role?(:franchisee_owner, @company) or current_user.has_role?(:franchisee_member, @company)) ? current_user.active_outlet.workflows.includes(:template).where(templates: {template_type: "onboarding"}).where.not(completed: true) : Workflow.includes([:company, :template]).where(company_id: @company.id, templates: {template_type: "onboarding"}).where.not(completed: true)
    @site_audit_workflows = (current_user.has_role?(:franchisee_owner, @company) or current_user.has_role?(:franchisee_member, @company)) ? current_user.active_outlet.workflows.includes(:template).where(templates: {template_type: "site_audit"}).where.not(completed: true) : Workflow.includes([:company, :template]).where(company_id: @company.id, templates: {template_type: "site_audit"}).where.not(completed: true)
    @royalty_collection_workflows = (current_user.has_role?(:franchisee_owner, @company) or current_user.has_role?(:franchisee_member, @company)) ? current_user.active_outlet.workflows.includes(:template).where(templates: {template_type: "royalty_collection"}).where.not(completed: true) : Workflow.includes([:company, :template]).where(company_id: @company.id, templates: {template_type: "royalty_collection"}).where.not(completed: true)
    # Find overdue onboarding workflow actions
    @outstanding_onboarding_actions = @company.workflow_actions.includes(workflow: :template).where(workflows: {templates: {template_type: "onboarding"}}).where.not(completed: true).order(:deadline).includes(:task)
    @outstanding_site_audit_actions = @company.workflow_actions.includes(workflow: :template).where(workflows: {templates: {template_type: "site_audit"}}).where.not(completed: true).order(:deadline).includes(:task)
    @outstanding_royalty_collection_actions = @company.workflow_actions.includes(workflow: :template).where(workflows: {templates: {template_type: "royalty_collection"}}).where.not(completed: true).order(:deadline).includes(:task)
    # Find total unread messages (notes). Currently, the system stores the user's last_click into comm hub in database. To find unread message, compare the note's created_at date. It should be larger than user's last_click to mimic an unread message.
    @unread_notes = @company.outlets.map{ |o| o.notes.includes(:notable).where(notable_id: o.id).where('created_at > ?', current_user.last_click_comm_hub)}.flatten
    @franchisee_unread_notes = current_user.active_outlet.notes.where('created_at > ?', current_user.last_click_comm_hub)
  end
  
  # Change user's outlet for franchisee with multiple outlets
  def change_outlet
    if current_user.update(user_params)
      redirect_to motif_root_path, notice: "Successfully changed outlet."
    else
      redirect_to motif_root_path, error: 'Sorry, there was an error when trying to switch outlet.'
    end
  end

  def financial_performance
    @company = current_user.company
    @outlets = @company.outlets
    #check if user has outlet, else find the outlet from the params, else display company
    @outlet = current_user.active_outlet ? current_user.active_outlet : (params[:outlet].present? ? Outlet.find(params[:outlet]) : @company)
  end

  def edit_report
    @source = current_user.active_outlet ? current_user.active_outlet : current_user.company
  end

  private

  def set_company
    @company = current_user.company
  end

  def franchisee_params
    params.require(:franchisee).permit(:name, :website_url, :established_date, :annual_turnover_rate, :currency, :address, :description, :contact_person_details, :profile_picture, :contact,  address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state], user_attributes: [:id, :first_name, :last_name, :email, :contact_number])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, :outlet_id, :stripe_card_token, :stripe_customer_id, settings_attributes: [:reminder_sms, :reminder_email, :reminder_slack, :reminder_whatsapp, :task_sms, :task_email, :task_slack, :task_whatsapp, :batch_sms, :batch_email, :batch_slack, :batch_whatsapp], :role_ids => [], company_attributes:[:id, :name, :connect_xero, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]])
  end
end
