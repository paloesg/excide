class Motif::HomeController < ApplicationController
  layout 'motif/application'

  before_action :authenticate_user!

  def index
    
  end

  # Change user's outlet for franchisee with multiple outlets
  def change_outlet
    if current_user.update(user_params)
      redirect_to motif_root_path, notice: "Successfully changed outlet."
    else
      redirect_to motif_root_path, error: 'Sorry, there was an error when trying to switch outlet.'
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, :outlet_id, :stripe_card_token, :stripe_customer_id, settings_attributes: [:reminder_sms, :reminder_email, :reminder_slack, :reminder_whatsapp, :task_sms, :task_email, :task_slack, :task_whatsapp, :batch_sms, :batch_email, :batch_slack, :batch_whatsapp], :role_ids => [], company_attributes:[:id, :name, :connect_xero, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]])
  end
end
