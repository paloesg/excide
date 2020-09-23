class HomeController < ApplicationController
  # controller for the menu page for users with multiple products
  def index
    if current_user.present?
      @products = current_user.company.products
    else
      redirect_to new_user_session_path
    end
  end

  # changes user's company
  def change_company
    if current_user.update(user_params)
      redirect_to root_path, notice: 'Company changed to ' + current_user.company.name + '.'
    else
      redirect_to root_path, error: 'Sorry, there was an error when trying to switch company.'
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, :stripe_card_token, :stripe_customer_id, settings_attributes: [:reminder_sms, :reminder_email, :reminder_slack, :reminder_whatsapp, :task_sms, :task_email, :task_slack, :task_whatsapp, :batch_sms, :batch_email, :batch_slack, :batch_whatsapp], :role_ids => [], company_attributes:[:id, :name, :connect_xero, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]])
  end
end
