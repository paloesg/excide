class Conductor::EventsController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company_and_clients
  before_action :set_staffers, only: [:new, :edit]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :reset, :create_allocations]
  before_action :set_user, only: [:new, :create, :edit, :update, :destroy]

  # GET /conductor/events
  # GET /conductor/events.json
  def index
    @date_from = params[:start_date].present? ? params[:start_date].to_date.beginning_of_month : Date.current.beginning_of_month
    @date_to = @date_from.end_of_month
    @events = Event.includes(:address, :client, :staffer, :event_type, [allocations: :user]).where(start_time: @date_from.beginning_of_day..@date_to.end_of_day)
    # Only show events relevant to associate if logged in as associate
    @events = @events.joins(:allocations).where(allocations: { user_id: @user.id }) if @user.has_role? :associate, :any
  end

  # GET /conductor/events/1
  # GET /conductor/events/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: { event: @event, address: @event.address } }
    end
  end

  # GET /conductor/events/new
  def new
    @event = Event.new
    @event.build_address
  end

  # GET /conductor/events/1/edit
  def edit
    @event.build_address if @event.address.blank?
  end

  # POST /conductor/events
  # POST /conductor/events.json
  def create
    if params['date_today'].present?
      params['event']['start_time'] = params['date_today'] +" "+ params['event']['start_time']
      params['event']['end_time'] = params['date_today'] +" "+ params['event']['end_time']
    end

    @event = Event.new(event_params)
    @event.company = @company

    respond_to do |format|
      if @event.save
        format.html { redirect_to conductor_events_path, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        set_staffers
        @event.build_address unless @event.address.present?
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
        format.js   { render js: @event.errors.to_json }
      end
    end
  end

  # PATCH/PUT /conductor/events/1
  # PATCH/PUT /conductor/events/1.json
  def update
    update_event_time = UpdateEventTime.new(@event, event_params['start_time'], event_params['end_time']).run

    respond_to do |format|
      if update_event_time.success? and @event.update(event_params)
        @event.update_event_notification
        flash[:notice] = update_event_time.message
        flash[:notice] << 'Event was successfully updated.'
        format.html { redirect_to conductor_events_path }
        format.json { render :show, status: :ok, location: @event }
      else
        set_staffers
        @event.build_address unless @event.address.present?
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conductor/events/1
  # DELETE /conductor/events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to conductor_events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def reset
    @event.allocations.destroy_all
    respond_to do |format|
      format.html { redirect_to conductor_events_url, notice: 'Event was successfully reset.' }
      format.json { head :no_content }
    end
  end

  def activities
    @get_activities = PublicActivity::Activity.where(recipient_type: "Event").order("created_at desc")
    @activities = Kaminari.paginate_array(@get_activities).page(params[:page]).per(10)
  end

  def create_allocations
    count = params[:count].to_i
    count.times do
      @allocation = Allocation.new(event_id: @event.id, allocation_date: @event.start_time, start_time: @event.start_time.strftime("%H:%M"), end_time: @event.end_time.strftime("%H:%M"), allocation_type: params[:type].underscore)
      unless @allocation.save
        format.json { render json: @allocation.errors, status: :unprocessable_entity  }
      end
    end
    respond_to do |format|
      format.json { render json: @event, status: :ok  }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = current_user.company.events.find(params[:id])
    end

    def set_user
      unless current_user.has_role? :admin, @company
        flash[:alert] = "You are not authorized to perform this action."
        redirect_to conductor_events_path
      end
    end

    def set_company_and_clients
      @user = current_user
      @company = @user.company
      @clients = Client.where(company_id: @company.id)
    end

    def set_staffers
      @staffers = User.where(company: @company).with_role :staffer, @company
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:event_type_id, :start_time, :end_time, :remarks, :location, :client_id, :staffer_id, address_attributes: [:line_1, :line_2, :postal_code])
    end
end
