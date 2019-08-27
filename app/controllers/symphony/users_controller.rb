class Symphony::UsersController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles, only: [:new, :create, :edit]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_company, :notification_settings, :update_notification]

  def index
    @users = User.where(company: @company).order(:id).without_role(:contractor, :any).includes(:roles)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.company = @company
    if @user.save
      redirect_to symphony_users_path, notice: 'User successfully created!'
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if @user.update(user_params)
      redirect_to symphony_users_path, notice: 'User successfully updated!'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to symphony_users_path, notice: 'User was successfully deleted.'
  end

  def change_company
    if @user.update(user_params) 
      if @user.company.connect_xero?
        #authenticate xero when switching company if connect_xero is true
        redirect_to XeroSessionsController.connect_to_xero(session)
      else
        redirect_to symphony_root_path, notice: 'Company changed.'
      end
    else
      redirect_to symphony_root_path, error: 'Unable to switch companies.'
    end
  end

  def notification_settings
  end

  def update_notification
    if @user.update(user_params)
      redirect_to symphony_root_path, notice: 'Notification settings updated successfully!'
    else
      redirect_to notification_settings_symphony_user(@user), alert: 'Notification settings not updated'
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_user
    @user = User.find_by(id: params[:id], company: @company)
  end

  def set_company_roles
    @company_roles = Role.where(resource_id: @company.id, resource_type: "Company")
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, settings_attributes: [:reminder_sms, :reminder_email, :reminder_slack, :task_sms, :task_email, :task_slack, :batch_sms, :batch_email, :batch_slack], :role_ids => [])
  end
end
