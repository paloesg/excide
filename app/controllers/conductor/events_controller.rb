class Conductor::EventsController < ApplicationController
  layout 'conductor/application'
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_clients
  before_action :set_staffers, only: [:new, :edit]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :reset, :create_allocations]
  before_action :get_users_projects_and_service_lines, only: [:index, :new, :edit, :create, :update]


  # GET /conductor/events
  # GET /conductor/events.json
  def index
    params[:start_date] = DateTime.current.beginning_of_month if params[:start_date].nil?
    date_from = params[:start_date].to_time.utc
    params[:end_date] = DateTime.current.end_of_month if params[:end_date].nil?
    date_to = params[:end_date].to_time.utc

    #filter event using scope setup in model
    @events = Event.includes(:address, :client, :staffer, :event_type, [allocations: :user]).company(@company.id)
    @events = @events.start_time(date_from..date_to)
    @events = @events.event(params[:event_types]) unless params[:event_types].blank?
    @events = @events.allocation(params[:allocation_users].split(",")) unless params[:allocation_users].blank?
    @events = @events.client(params[:project_clients].split(",")) unless params[:project_clients].blank?
    #using tagged_with means can only search with 1 selected value
    @events = Event.tagged_with(params[:service_line]) unless params[:service_line].blank?

    if @user.has_role?(:admin, @company) or @user.has_role?(:staffer, @company)
    @user_event_count = Hash.new
      User.where(department: @user.department).each do |user|
        @user_event_count[user.full_name] = []
        @user_event_count[user.full_name] << @events.joins(:allocations).where(allocations: { user_id: user.id }).map(&:start_time).uniq.count
        @user_event_count[user.full_name] << @events.joins(:allocations).where(allocations: { user_id: user.id }).map(&:number_of_hours).sum.to_i
      end
    else
      # Only show their own timesheet events unless they are admin or staffer, as the 2 can see all events
      @events = @events.joins(:allocations).where(allocations: { user_id: @user.id })
    end

    # Create new form in index page
    @event = Event.new
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
    # Placeholder for event's end time as there is no end time in the form
    @event.end_time = @event.start_time + 1.hour
    @event.company = @company
    @event.service_line_list.add(params[:service_line]) if params[:service_line].present?
    @event.project_list.add(params[:project]) if params[:project].present?
    respond_to do |format|
      if @event.save
        # Allocate yourself to the timesheet allocation
        @timesheet_allocation = GenerateTimesheetAllocationService.new(@event, params[:user].present? ? User.find(params[:user]) : current_user).run
        if @timesheet_allocation.success?
          format.html { redirect_to conductor_events_path, notice: 'Event created successfully.'}
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
    respond_to do |format|
      if @event.update(event_params)
        flash[:notice] = 'Event was successfully updated.'
        format.json { render json: @event, status: :ok }
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

  def import
    @events = GenerateEventsService.new(params[:file], current_user).run
    respond_to do |format|
      if @events.success?
        format.html { redirect_to conductor_events_path, notice: "Events imported." }
      else
        format.html { redirect_to conductor_events_path, alert: "Event was not created due to error: #{@events.message}." }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = current_user.company.events.find(params[:id])
  end

  def set_clients
    @clients = Client.where(company_id: @company.id).sort_by(&:name)
  end

  def set_staffers
    @staffers = User.where(company: @company).with_role :staffer, @company
  end

  def get_users_projects_and_service_lines
    # To be tagged using acts_as_taggable_on gem
    @service_lines = ActsAsTaggableOn::Tag.for_context(:service_lines).map(&:name).sort
    @projects = ActsAsTaggableOn::Tag.for_context(:projects).map(&:name).sort
    # Get users who have roles consultant, associate and staffer so that staffer can allocate these users
    @users = User.joins(:roles).where({roles: {name: ["consultant", "associate", "staffer"], resource_id: @company.id}}).uniq.sort_by(&:first_name)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:event_type_id, :start_time, :end_time, :remarks, :location, :client_id, :staffer_id, :service_line_list, :project_list, :number_of_hours, address_attributes: [:line_1, :line_2, :postal_code, :city, :country, :state])
  end
end
