class Symphony::RolesController < ApplicationController
  layout "dashboard/application"
  before_action :set_company
  before_action :set_role, only: [:edit, :update, :destroy]

  def index
    @roles = Role.where(resource_id: @company.id, resource_type: "Company")
  end

  def new
    @users = User.where(company: @company).order(:id).pluck(:email, :id)
    @role = Role.new
  end

  def create
    @role = Role.find_or_create_by(role_params)
    if @role.save
      redirect_to symphony_roles_path, notice: 'Role successfully created!'
    else
      render :new
    end
  end

  def edit
    @users = User.where(company: @company).order(:id).pluck(:email, :id)
  end

  def update
    if @role.update(role_params)
      redirect_to symphony_roles_path, notice: 'Role successfully updated!'
    else
      render :edit
    end
  end

  def destroy
    @role.destroy
    redirect_to symphony_roles_path, notice: 'Role was successfully deleted.'
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def set_company
    @user = current_user
    @company = @user.company
  end

  def role_params
    params.require(:role).permit(:name, :resource_id, :resource_type)
  end
end
