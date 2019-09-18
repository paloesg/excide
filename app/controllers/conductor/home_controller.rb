class Conductor::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company_and_roles

  def show
    date_from = params[:start_date] ? params[:start_date].to_date.beginning_of_month : Date.current.beginning_of_month
    date_to = date_from.to_date + 1.month
    # get_activations = Activation.where(company: @company, start_time: date_from..date_to)
    @activations = Activation.company(@company.id)
    @activations = @activations.start_time(date_from..date_to)
    @activations = @activations.activation(params[:activation_type]) unless params[:activation_type].blank?
    @activations = @activations.allocation(params[:allocator]) unless params[:allocator].blank?
    @activations = @activations.client(params[:client]) unless params[:client].blank?

    # Only show activations relevant to contractor if logged in as contractor
    @activations = @activations.joins(:allocations).where(allocations: { user_id: @user.id }) if @user.has_role? :contractor, :any
    @upcoming_activations = @activations.where("activations.end_time > ?", Time.current)

    @activities = PublicActivity::Activity.where(recipient_type: "Activation").order("created_at desc")

    @activation = Activation.new
    @activation.build_address
    @clients = Client.where(company_id: @company.id)
    @event_owners = User.where(company: @company).with_role :event_owner, @company
  end

  private

  def set_company_and_roles
    @user = current_user
    @company = @user.company
    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
  end
end
