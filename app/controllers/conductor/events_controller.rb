class Conductor::EventsController < ApplicationController
  layout 'conductor/application'
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_staffers, only: [:new, :edit]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :reset, :create_allocations]
  before_action :set_tags, only: [:index, :new, :edit, :create, :update, :edit_tags, :create_tags]


  # GET /conductor/events
  # GET /conductor/events.json
  def index
    params[:start_date] = DateTime.current.beginning_of_month if params[:start_date].nil?
    date_from = params[:start_date].to_time.utc
    params[:end_date] = DateTime.current.end_of_month if params[:end_date].nil?
    date_to = params[:end_date].to_time.utc

    #filter event using scope setup in model
    @events = Event.includes(:address, :staffer, [allocations: :user]).company(@company.id)
    @events = @events.start_time(date_from..date_to)
    @events = @events.department(@department) unless @user.has_role?(:admin, @company)
    @events = @events.allocation(params[:allocation_users].split(",")) unless params[:allocation_users].blank?
    #using tagged_with means can only search with 1 selected value
    @events = @events.includes(:event_categories).where(event_categories: { category_id: params[:service_line] }) unless params[:service_line].blank?
    @events = Event.where(id: @events.map(&:id)).includes(:event_categories).where(event_categories: { category_id: params[:project_clients] }) unless params[:project_clients].blank?
    #combine department and general categories, then sort alphabetically
    @clients = (@clients + @general_clients).sort_by(&:name)
    @service_lines = (@service_lines + @general_service_lines).sort_by(&:name)
    @projects = (@projects + @general_projects).sort_by(&:name)
    @tasks = (@tasks + @general_tasks).sort_by(&:name)

    if @user.has_role?(:admin, @company) or @user.has_role?(:staffer, @company)
    @user_event_count = Hash.new
    @user_list = @user.has_role?(:admin, @company) ? User.where(company: @company): User.where(department: @department)
      @user_list.each do |user|
        @user_event_count[user.full_name] = []
        @user_event_count[user.full_name] << @events.joins(:allocations).where(allocations: { user_id: user.id }).map(&:start_time).uniq.count
        @user_event_count[user.full_name] << @events.joins(:allocations).where(allocations: { user_id: user.id }).filter_map(&:number_of_hours).sum.to_i
      end
    else
      # Only show their own timesheet events unless they are admin or staffer, as the 2 can see all events
      @events = @events.joins(:allocations).where(allocations: { user_id: @user.id })
    end
    @events_all = @events.map(&:id)
    @events = Kaminari.paginate_array(@events.order(start_time: :desc)).page(params[:page]).per(10)

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
    @client = Category.find(params[:client]) if params[:client].present?
    @service_line = Category.find(params[:service_line]) if params[:service_line].present?
    @project = Category.find(params[:project]) if params[:project].present?
    @task = Category.find(params[:task]) if params[:task].present?
    @event.categories << @client << @service_line << @project << @task
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
      if event_params[:client_category] || event_params[:service_line_category] || event_params[:project_category] || event_params[:task_category]
        if update_categories(@event, event_params)
          flash[:notice] = 'Event was successfully updated.'
          format.json { render json: @event, status: :ok }
        end
      elsif @event.update(event_params)
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
        format.html { redirect_to conductor_events_path, notice: "Your timesheet is still being processed. Please wait a while and refresh." }
      else
        format.html { redirect_to conductor_events_path, alert: "Event was not created due to error: #{@events.message}." }
      end
    end
  end

  def edit_tags
    if @user.has_role?(:admin, @company)
      @clients = @general_clients
      @projects = @general_projects
      @service_lines = @general_service_lines
      @tasks = @general_tasks
    end
    @client_tags, @project_tags, @service_line_tags, @task_tags = [], [], [], []
    @clients.sort_by(&:name).each { |c| @client_tags << {value: c.name, id: c.id}.as_json }
    @projects.sort_by(&:name).each { |p| @project_tags << {value: p.name, id: p.id}.as_json }
    @service_lines.sort_by(&:name).each { |sl| @service_line_tags << {value: sl.name, id: sl.id}.as_json }
    @tasks.sort_by(&:name).each { |t| @task_tags << {value: t.name, id: t.id}.as_json }
    @client_tags = @client_tags.to_json
    @project_tags = @project_tags.to_json
    @service_line_tags = @service_line_tags.to_json
    @task_tags = @task_tags.to_json
  end

  def create_tags
    @category = Category.new(name: helpers.titleize_keep_uppercase(params[:value]), category_type: params[:type], department: @user.has_role?(:admin, @company) ? nil : @department)
    respond_to do |format|
      if @category.save
        format.json { render json: @category, status: :ok }
      else
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_tags
    @category = Category.find(params[:id])
    @category.name = helpers.titleize_keep_uppercase(params[:value])
    respond_to do |format|
      if @category.save
        format.json { render json: @category, status: :ok }
      else
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_categories(event, event_params)
    if event_params[:client_category]
      event.categories.delete(event.categories.where(category_type: "client"))
      event.categories << Category.find(event_params[:client_category])
    elsif event_params[:service_line_category]
      event.categories.delete(event.categories.where(category_type: "service_line"))
      event.categories << Category.find(event_params[:service_line_category])
    elsif event_params[:project_category]
      event.categories.delete(event.categories.where(category_type: "project"))
      event.categories << Category.find(event_params[:project_category])
    elsif event_params[:task_category]
      event.categories.delete(event.categories.where(category_type: "task"))
      event.categories << Category.find(event_params[:task_category])
    end
    event.save
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = current_user.company.events.find(params[:id])
  end

  def set_staffers
    @staffers = User.where(company: @company).with_role :staffer, @company
  end

  def set_tags
    # To be tagged using acts_as_taggable_on gem
    @department = @user.department
    @service_lines = Category.where(category_type: "service_line", department: @department)
    @projects = Category.where(category_type: "project", department: @department)
    @clients = Category.where(category_type: "client", department: @department)
    @tasks = Category.where(category_type: "task", department: @department)
    @general_service_lines = Category.where(category_type: "service_line", department: nil)
    @general_projects = Category.where(category_type: "project", department: nil)
    @general_clients = Category.where(category_type: "client", department: nil)
    @general_tasks = Category.where(category_type: "task", department: nil)
    # Get users who have roles consultant, associate and staffer so that staffer can allocate these users
    @users = User.where(department: @department).order(:first_name)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:event_type_id, :start_time, :end_time, :remarks, :location, :client_id, :staffer_id, :client_category, :service_line_category, :project_category, :task_category, :number_of_hours, address_attributes: [:line_1, :line_2, :postal_code, :city, :country, :state])
  end
end
