class Conductor::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company_and_roles

  def show
    date_from = params[:start_date] ? params[:start_date].to_date.beginning_of_month : Date.today.beginning_of_month
    date_to = date_from.to_date + 1.month
    activation_type = params[:activation_type].blank? ? 'all' : params[:activation_type]
    @activations = Activation.where(company: @company, start_time: date_from..date_to).send(activation_type)
    # Only show activations relevant to contractor if logged in as contractor
    @activations = @activations.joins(:allocations).where(allocations: { user_id: @user.id }) if @user.has_role? :contractor, :any

    @activities = PublicActivity::Activity.where(recipient_type: "Activation").order("created_at desc")
  end

  private

  def set_company_and_roles
    @user = current_user
    @company = @user.company
    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
  end
end
