class Conductor::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company_and_clients
  before_action :set_staffers, only: [:new, :edit]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :reset, :create_allocations]
  before_action :get_users_and_service_lines, only: [:new, :edit, :create, :update]


  # GET /conductor/events
  # GET /conductor/events.json
  def index
    @date_from = params[:start_date].present? ? params[:start_date].to_date.beginning_of_month : Date.current.beginning_of_month
    @date_to = @date_from.end_of_month
    # Filter by users
    # @events = @company.events.joins(:allocations).where(allocations: { user_id: User.find(params[:users].to_i) }) if params[:users].present?
    # Staffer or admin gets to see all the event listing
    if @user.has_role?(:staffer, @company) or @user.has_role?(:admin, @company)
      @events = @company.events.includes(:address, :client, :staffer, :event_type, [allocations: :user]).where(start_time: @date_from.beginning_of_day..@date_to.end_of_day)
      # params[:users].present? ? @events.includes(:address, :client, :staffer, :event_type, [allocations: :user]).where(start_time: @date_from.beginning_of_day..@date_to.end_of_day) : @company.events.includes(:address, :client, :staffer, :event_type, [allocations: :user]).where(start_time: @date_from.beginning_of_day..@date_to.end_of_day)
    else
      # Only show events relevant to associate if logged in as associate or consultant
      @events = @company.events.joins(:allocations).where(allocations: { user_id: @user.id })
      # params[:users].present? ? @events.joins(:allocations).where(allocations: { user_id: @user.id }) : @company.events.joins(:allocations).where(allocations: { user_id: @user.id })
    end 
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
    @event.tag_list.add(params[:service_line]) if params[:service_line].present?
    respond_to do |format|
      if @event.save
        # Allocate yourself to the timesheet allocation
        @timesheet_allocation = GenerateTimesheetAllocationService.new(@event, params[:user].present? ? User.find(params[:user]) : current_user).run if current_user.has_role? :associate, @company or current_user.has_role? :consultant, @company or current_user.has_role? :staffer, @company
        if current_user.has_role? :admin, @company or @timesheet_allocation.success?
          format.json { render :show, status: :created, location: @event }
          format.js   { render js: 'Turbolinks.visit(location.toString());' }
        else
          # Inform user if timesheet was not allocated
          format.html { redirect_to conductor_root_path, alert: "Event was not created due to error: #{@timesheet_allocation.message}."}
        end
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
    update_event_time = UpdateEventTime.new(@event, DateTime.current, DateTime.current + 1.hour, params[:user].present? ? User.find_by(id: params[:user]) : current_user, params[:service_line]).run

    respond_to do |format|
      if update_event_time.success? and @event.update(event_params)
        # @event.update_event_notification
        flash[:notice] = 'Event was successfully updated.'
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

  def set_company_and_clients
    @user = current_user
    @company = @user.company
    @clients = Client.where(company_id: @company.id)
  end

  def set_staffers
    @staffers = User.where(company: @company).with_role :staffer, @company
  end

  def get_users_and_service_lines
    # To be tagged using acts_as_taggable_on gem
    @service_lines = ['NA', 'Virtual Financial Analysis', 'Financial Function Outsourcing', 'Fundraising Advisory', 'Exit Planning', 'Digital Implementation', 'Digital Strategy']
    # Get users who have roles consultant, associate and staffer so that staffer can allocate these users
    @users = User.joins(:roles).where({roles: {name: ["consultant", "associate", "staffer"], resource_id: @company.id}}).uniq
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:event_type_id, :start_time, :end_time, :remarks, :location, :client_id, :staffer_id, :tag_list, :number_of_hours, address_attributes: [:line_1, :line_2, :postal_code, :city, :country, :state])
  end
end
