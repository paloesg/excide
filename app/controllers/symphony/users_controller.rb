class Symphony::UsersController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
    @users = User.where(company: @company)
  end

  private

  def set_company
    @admin_user = current_user
    @company = @admin_user.company
  end
end