class Overture::RolesController < ApplicationController
  layout 'overture/application'

  before_action :set_company
  before_action :set_company_users, only: :index
  before_action :set_role, except: [:index, :create]

  def index
    # Find all company's groups (except for admin and member)
    @roles = @company.roles.where.not(name: ["admin", "member"]).order(created_at: :desc)
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      update_users_role
      redirect_to overture_roles_path, notice: 'Group successfully created!'
    else
      render :new
    end
  end

  def update
    if @role.update(role_params)
      update_users_role
      redirect_to overture_roles_path, notice: 'Group successfully updated!'
    else
      render :edit
    end
  end

  def destroy
    @role.destroy
    redirect_to overture_roles_path, notice: 'Group was successfully deleted.'
  end

  private
  def set_role
    @role = @company.roles.find(params[:id])
  end

  def set_company
    @user = current_user
    @company = @user.company
  end

  def set_company_users
    # Find users whose company is investor company and has contact searchable
    @investor_users = Company.includes(:contacts).where(company_type: "investor", contacts: {  searchable: true }).map(&:users).flatten
  end

  def update_users_role
    users = User.where(id: params[:role][:user_ids])
    @role.users.each do |user|
      user.remove_role @role.name, @role.resource
    end
    users.each do |user|
      user.add_role @role.name, @role.resource
    end
  end

  def role_params
    params.require(:role).permit(:name, :resource_id, :resource_type, user_ids: [])
  end
end
