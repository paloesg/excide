class Motif::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles, only: [:new, :create, :edit]
  before_action :set_user, except: [:index, :new, :create]

  def index
    @users = User.joins(:roles).where(:roles => {resource_id: @company.id}).order(:id).uniq
  end

  # def show
  # end

  # def new
  #   @user = User.new
  # end

  # def create
  #   @user = User.find_or_initialize_by(email: user_params[:email])
  #   if @user.first_name.nil?
  #     @user.update(user_params)
  #     message = 'User successfully created!'
  #   else
  #     updated_roles = Role.where(id: params[:user][:role_ids])
  #     @user.roles << updated_roles
  #     message = 'User successfully added!'
  #   end
  #   @user.company = @company
  #   if @user.save
  #     redirect_to symphony_users_path, notice: message
  #   else
  #     render :new
  #   end
  # end

  # def edit
  #   @user = User.find(params[:id])
  # end

  # def update
  #   # Get all the updated roles by finding the role instance
  #   updated_roles = Role.where(id: params[:user][:role_ids])
  #   # Remove all the roles in that company and then add in the new
  #   @user.roles.where(resource_id: current_user.company.id).each do |role|
  #     @user.remove_role(role.name, current_user.company)
  #   end
  #   # Append update roles to user's roles
  #   @user.roles << updated_roles
  #   if @user.update(first_name: params[:user][:first_name], last_name: params[:user][:last_name], email: params[:user][:email], contact_number: params[:user][:contact_number])
  #     redirect_to symphony_users_path, notice: 'User successfully updated!'
  #   else
  #     render :edit
  #   end
  # end

  # def destroy
  #   @user.destroy
  #   redirect_to symphony_users_path, notice: 'User was successfully deleted.'
  # end

  

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
