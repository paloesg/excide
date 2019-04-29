class Symphony::UsersController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles, only: [:new, :create, :edit]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_company]

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
      #clear xero session after switching company successfully and check that session is present
      session[:xero_auth].clear if session[:xero_auth].present?
      redirect_to symphony_root_path, notice: "Company changed to #{Company.find(user_params[:company_id]).name}."
    else
      redirect_to symphony_root_path, error: 'Unable to switch companies.'
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
    params.require(:user).permit(:first_name, :last_name, :email, :contact_number, :company_id, :role_ids => [])
  end
end
