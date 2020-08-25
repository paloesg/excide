class Conductor::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company_and_clients
  before_action :set_staffers, only: [:new, :edit]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :reset, :create_allocations]
  before_action :get_users_and_service_lines, only: [:index, :new, :edit, :create, :update]


  # GET /conductor/events
  # GET /conductor/events.json
  def index
    date_from = params[:start_date].present? ? params[:start_date].to_date : Date.current.beginning_of_month
    date_to = params[:end_date].present? ? params[:end_date].to_date : Date.current.end_of_month

    #filter event using scope setup in model
    @events = Event.includes(:address, :client, :staffer, :event_type, [allocations: :user]).company(@company.id)
    @events = @events.start_time(date_from..date_to)
    @events = @events.event(params[:event_types]) unless params[:event_types].blank?
    @events = @events.allocation(params[:allocation_users]) unless params[:allocation_users].blank?
    @events = @events.client(params[:project_clients]) unless params[:project_clients].blank?
    
    # Only show events relevant to associate if logged in as associate or consultant
    @events = @events.joins(:allocations).where(allocations: { user_id: @user.id }) if @user.has_role?(:associate, @company) or @user.has_role?(:consultant, @company)

    # Create new form in index page
    @event = Event.new
    @event.build_address
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
