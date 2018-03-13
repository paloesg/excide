class Conductor::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company_and_roles

  def show
    date_from = params[:start_date] ? params[:start_date].to_date.beginning_of_month : Date.today.beginning_of_month
    date_to = date_from.to_date + 1.month
    @activations = Activation.where(company: @company, start_time: date_from..date_to)
  end

  private

  def set_company_and_roles
    @user = current_user
    @company = @user.company
    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
  end

end
