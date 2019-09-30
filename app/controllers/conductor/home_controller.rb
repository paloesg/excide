class Conductor::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company_and_roles

  def show
    date_from = params[:start_date] ? params[:start_date].to_date.beginning_of_month : Date.current.beginning_of_month
    date_to = date_from.to_date + 1.month
    get_events = Event.where(company: @company, start_time: date_from..date_to)

    if params[:event_type].blank?
      @events = get_events.all
    else
      @events = get_events.joins(:event_type).where(event_types: {slug: params[:event_type]})
    end

    #split params to set default selected in selectize
    params[:event_types] = params[:event_types].split(',') unless params[:event_types].blank?
    params[:allocation_users] = params[:allocation_users].split(',') unless params[:allocation_users].blank?
    params[:project_clients] = params[:project_clients].split(',') unless params[:project_clients].blank?

    #filter event using scope setup in model
    @events = Event.includes(:address, :client, :staffer, :event_type, [allocations: :user]).company(@company.id)
    @events = @events.start_time(date_from..date_to)
    @events = @events.event(params[:event_types]) unless params[:event_types].blank?
    @events = @events.allocation(params[:allocation_users]) unless params[:allocation_users].blank?
    @events = @events.client(params[:project_clients]) unless params[:project_clients].blank?

    # Only show events relevant to associate if logged in as associate
    @events = @events.joins(:allocations).where(allocations: { user_id: @user.id }) if @user.has_role? :associate, :any
    @upcoming_events = @events.where("events.end_time > ?", Time.current)

    @activities = PublicActivity::Activity.includes(:owner).where(recipient_type: "Event").order("created_at desc")

    @event = Event.new
    @event.build_address
    @clients = Client.where(company_id: @company.id)
    @staffers = User.where(company: @company).with_role :staffer, @company
  end

  private

  def set_company_and_roles
    @user = current_user
    @company = @user.company
    @roles = @user.roles.where(resource_id: @company.id, resource_type: "Company")
  end
end
