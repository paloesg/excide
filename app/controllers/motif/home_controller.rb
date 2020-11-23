class Motif::HomeController < ApplicationController
  layout 'motif/application'
  
  before_action :set_company
  before_action :set_franchisee, except: :index
  before_action :authenticate_user!

  def index
    @franchisees = Franchisee.includes(:company).where(company_id: @company.id)
    @outlets = Outlet.includes(:franchisee).where(franchisees: { company_id: @company.id })
    @workflows = current_user.has_role?(:franchisee_owner, current_user.company) ? current_user.outlet.workflows : Workflow.includes(:company).where(company_id: @company.id)
    # Find overdue tasks
    @outstanding_onboarding_actions = WorkflowAction.includes(:workflow).all_user_actions(current_user).where.not(completed: true, deadline: nil).where(company: current_user.company).order(:deadline).includes(:task)
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
    @outlets = @company.franchisees.map{|f| f.outlets}.flatten
    #check if user has outlet, else find the outlet from the params, else display company
    @outlet = current_user.outlet ? current_user.outlet : (params[:outlet].present? ? Outlet.find(params[:outlet]) : @company)
  end

  def edit_report
    @source = current_user.outlet ? current_user.outlet : current_user.company
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_franchisee
    @franchisee = Franchisee.find(params[:id])
  end

  def franchisee_params
    params.require(:franchisee).permit(:name, :website_url, :established_date, :annual_turnover_rate, :currency, :address, :description, :contact_person_details, :profile_picture, :contact,  address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state], user_attributes: [:id, :first_name, :last_name, :email, :contact_number])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, :outlet_id, :stripe_card_token, :stripe_customer_id, settings_attributes: [:reminder_sms, :reminder_email, :reminder_slack, :reminder_whatsapp, :task_sms, :task_email, :task_slack, :task_whatsapp, :batch_sms, :batch_email, :batch_slack, :batch_whatsapp], :role_ids => [], company_attributes:[:id, :name, :connect_xero, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]])
  end
end
