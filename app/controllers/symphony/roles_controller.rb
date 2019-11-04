class Symphony::RolesController < ApplicationController
  layout "dashboard/application"
  before_action :set_company

  def index
    @roles = Role.all
  end

  def set_company
    @user = current_user
    @company = @user.company
  end
end
