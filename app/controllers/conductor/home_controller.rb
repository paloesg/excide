class Conductor::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company_and_roles

  def show
    date_from = params[:start_date]&.to_date || Date.today
    date_to = date_from.to_date + 1.month
    @activations = Activation.where(company: @company, start_time: date_from.beginning_of_day..date_to.end_of_day)
  end

  private

  def set_company_and_roles
    @user = current_user
    @company = @user.company
    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
  end

end
