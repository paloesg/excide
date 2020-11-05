class Symphony::RolesController < ApplicationController
  layout 'symphony/application'
  
  before_action :set_company, :set_company_users
  before_action :set_role, only: [:edit, :update, :destroy]

  def index
    @roles = Role.where(resource_id: @company.id, resource_type: "Company")
  end

  def new
    @users = User.where(company: @company).order(:id)
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      update_users_role
      redirect_to symphony_roles_path, notice: 'Role successfully created!'
    else
      render :new
    end
  end

  def edit
    @users = User.joins(:roles).where(roles: {resource_id: @company.id}).order(:id)
  end

  def update
    if @role.update(role_params)
      update_users_role
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

  def update_users_role
    users = User.where(id: params[:role][:user_ids])
    @role.users.each do |user|
      user.remove_role @role.name, @role.resource
    end
    users.each do |user|
      user.add_role @role.name, @role.resource
    end
  end

  def set_role
    @role = @company.roles.find(params[:id])
  end

  def set_company_users
    @company_users = User.where(company_id: @company.id)
  end

  def role_params
    params.require(:role).permit(:name, :resource_id, :resource_type, user_ids: [])
  end
end
