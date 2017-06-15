class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard

  private

  def set_dashboard
    @user = current_user
    @company = @user.company
  end
end
