class Motif::HomeController < ApplicationController
  layout 'motif/application'
  include Motif::WorkflowsHelper
  include Motif::OutletsHelper

  before_action :authenticate_user!
  before_action :set_company

  def index
    # Get all outlets (sub franchised or direct owned)
    @outlets = get_outlets_by_type(nil, @company)
    # Check franchisee expiry date within 1 month of expiry
    @outlets_expiring = @outlets.filter_map{|o| o.franchisee if (o&.franchisee&.expiry_date.present? and o&.franchisee&.expiry_date < DateTime.current + 1.month)}
    # This variable is only being used by unit franchisee
    @workflows = current_user.active_outlet.workflows if current_user.active_outlet.present?
    # Get number of announcements for that company
    @posts = @company.posts
    # Find workflows that is not completed yet
    @onboarding_workflows = get_workflows(current_user, "onboarding")
    @site_audit_workflows = get_workflows(current_user, "site_audit")
    @royalty_collection_workflows = get_workflows(current_user, "royalty_collection")
    # Find outlets from workflows that have outstanding wfa
    @outstanding_onboarding_actions_outlets = @onboarding_workflows.map{|wf| wf.workflow_actions.map{|wfa| wf.outlet if (wfa.deadline.present? and wfa.deadline <= DateTime.current)}}.flatten.compact
    @outstanding_site_audit_actions_outlets = @site_audit_workflows.map{|wf| wf.workflow_actions.map{|wfa| wf.outlet if (wfa.deadline.present? and wfa.deadline <= DateTime.current)}}.flatten.compact
    @outstanding_royalty_collection_actions_outlets = @site_audit_workflows.map{|wf| wf.workflow_actions.map{|wfa| wf.outlet if (wfa.deadline.present? and wfa.deadline <= DateTime.current)}}.flatten.compact
    # Find outlet that is awaiting approval (there's a bell to notify franchisor)
    @waiting_approval_onboarding_outlets = @onboarding_workflows.map{|wf| wf.workflow_actions.map{|wfa| wf.outlet if wfa.notify_status? }}.flatten.compact
    @waiting_approval_site_audit_outlets = @site_audit_workflows.map{|wf| wf.workflow_actions.map{|wfa| wf.outlet if wfa.notify_status? }}.flatten.compact
    @waiting_approval_royalty_collection_outlets = @royalty_collection_workflows.map{|wf| wf.workflow_actions.map{|wfa| wf.outlet if wfa.notify_status? }}.flatten.compact
    # The system stores the user's last_click into sharing hub in database, compare the note's created_at date with the last_click. It should be larger than user's last_click to mimic an unread message. Reject if note's user is current_user
    @unread_notes = Note.where(notable_id: @company.outlets.map(&:id)).where('created_at > ?', current_user.last_click_comm_hub).where.not(user: current_user)
    # Check if active outlet present since franchisor wont have active outlet
    @franchisee_unread_notes = current_user.active_outlet.notes.where('created_at > ?', current_user.last_click_comm_hub).where.not(user: current_user) if current_user.active_outlet.present?
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
    @franchisees = @company.franchisees
    #check if user has outlet, else find the outlet from the params, else display company
    @source = current_user&.active_outlet&.franchisee ? current_user.active_outlet.franchisee : (params[:franchisee].present? ? @company.franchisees.find(params[:franchisee]) : @company)
  end

  def edit_report
    @source = current_user.active_outlet ? current_user.active_outlet : current_user.company
  end

  def usage
    # Get all outlets (sub franchised or direct owned)
    @outlets = get_outlets_by_type(nil, @company)
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
