class Symphony::UsersController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
    @users = User.where(company: @company)
  end

  def show
    @user = User.find_by(id: params[:id], company: @company)
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

  private

  def set_company
    @company = current_user.company
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :email, :contact_number, :company_id)
  end
end