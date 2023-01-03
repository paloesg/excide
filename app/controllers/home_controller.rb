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
      # user's company has multiple products
      if current_user.company.products.length > 1
        # redirect to same page, if cannot they are redirected instead to the product selection page
        redirect_back fallback_location: root_path, notice: 'Company changed to ' + current_user.company.name + '.'
      # user's company only has 1 product
      elsif current_user.company.products.length == 1
        # redirect to same page, if cannot they are redirected instead to the sole product's page
        if current_user.company.products[0] == "symphony"
          redirect_back fallback_location: symphony_root_path, notice: 'Company changed to ' + current_user.company.name + '.'
        elsif current_user.company.products[0] == "motif"
          redirect_back fallback_location: motif_root_path, notice: 'Company changed to ' + current_user.company.name + '.'
        end
      end
    else
      redirect_to root_path, error: 'Sorry, there was an error when trying to switch company.'
    end
  end

  def welcome

  end

  # Returns file.json to retrieve Dedoco complete signing link
  def file
    @document = Document.find("24a405b3-2f31-447c-aeae-6e2a1f0d2188")
    render json: { file: @document.base_64_file_data }
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, :stripe_card_token, :stripe_customer_id, settings_attributes: [:reminder_sms, :reminder_email, :reminder_slack, :reminder_whatsapp, :task_sms, :task_email, :task_slack, :task_whatsapp, :batch_sms, :batch_email, :batch_slack, :batch_whatsapp], :role_ids => [], company_attributes:[:id, :name, :connect_xero, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]])
  end
end
