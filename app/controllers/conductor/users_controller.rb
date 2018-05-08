class Conductor::UsersController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles, only: [:new, :create, :edit]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.where(company: @company).with_role :contractor, @company
  end

  def show
    @availabilities = Availability.where(user: @user)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.company = @company
    if user_params[:max_hours_per_week].blank?
      @user.valid?
      @user.errors.add(:max_hours_per_week, "must be present for contractors")
      render :new
    elsif @user.save
      @user.add_role :contractor, @company
      @user.add_role_contractor_ic params[:contractor_in_charge]
      redirect_to conductor_users_path, notice: 'User successfully created!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if user_params[:max_hours_per_week].blank?
      @user.valid?
      @user.errors.add(:max_hours_per_week, "must be present for contractors")
      render :edit
    elsif @user.update(user_params)
      @user.add_role_contractor_ic params[:contractor_in_charge]
      redirect_to conductor_user_path, notice: 'User successfully updated!'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to conductor_users_path, notice: 'User was successfully deleted.'
  end

  def export
    @users = User.where(company: @company).with_role :contractor, @company
    send_data @users.contractors_to_csv, filename: "Contractors-#{Date.today}.csv"
  end

  def import
    @users = User.csv_to_contractors(params[:csv_file], @company)
    flash[:notice] = "#{@users["imported"]} contractors imported succesfully. "
    flash[:notice] << "#{@users["exist"]} contractors already exist in system." if @users["exist"] != 0
    redirect_to conductor_users_path
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_user
    if current_user.id == params[:id].to_i or current_user.has_role? :admin, @company
      @user = User.find_by(id: params[:id], company: @company)
    else
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to conductor_user_path current_user
    end
  end

  def set_company_roles
    @company_roles = Role.where(resource_id: @company.id, resource_type: "Company")
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :password, :email, :contact_number, :nric, :date_of_birth, :max_hours_per_week, :bank_name, :bank_account_type, :bank_account_number, :company_id, :role_ids => [])
  end
end