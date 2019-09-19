class Conductor::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company_and_roles

  def show
    date_from = params[:start_date] ? params[:start_date].to_date.beginning_of_month : Date.current.beginning_of_month
    date_to = date_from.to_date + 1.month

    #split params to set default selected in selectize
    params[:activation_types] = params[:activation_types].split(',') unless params[:activation_types].blank? 
    params[:allocation_users] = params[:allocation_users].split(',') unless params[:allocation_users].blank?
    params[:project_clients] = params[:project_clients].split(',') unless params[:project_clients].blank?
    
    #filter activation using scope setup in model
    @activations = Activation.company(@company.id)
    @activations = @activations.start_time(date_from..date_to)
    @activations = @activations.activation(params[:activation_types]) unless params[:activation_types].blank?
    @activations = @activations.allocation(params[:allocation_users]) unless params[:allocation_users].blank?
    @activations = @activations.client(params[:project_clients]) unless params[:project_clients].blank?

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
