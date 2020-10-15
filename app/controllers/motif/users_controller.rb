class Motif::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles
  before_action :set_user, except: [:index, :new, :create]

  def index
    @users = User.joins(:roles).where(:roles => {resource_id: @company.id}).order(:id).uniq
  end

  def update
    # AJAX request to update user type from motif teammates
    @user = @company.users.find(params[:user_id])
    @role = @company.roles.find(params[:role_id])
    respond_to do |format|
      # # check if update comes from drag and drop or from remarks. If folder_id is not present, then update remarks
      # if @user.update
      #   format.json { render json: { link_to: motif_documents_path, status: "ok" } }
      # else
      #   format.html { redirect_to motif_documents_path }
      #   format.json { render json: @document.errors, status: :unprocessable_entity }
      # end
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def set_company_roles
    @company_roles = Role.where(resource_id: @company.id, resource_type: "Company")
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, :stripe_card_token, :stripe_customer_id, settings_attributes: [:reminder_sms, :reminder_email, :reminder_slack, :reminder_whatsapp, :task_sms, :task_email, :task_slack, :task_whatsapp, :batch_sms, :batch_email, :batch_slack, :batch_whatsapp], :role_ids => [], company_attributes:[:id, :name, :connect_xero, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]])
  end
end
