class Conductor::AllocationsController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_allocation, only: [:show, :edit, :update, :destroy]
  before_action :set_associate, only: [:new, :edit]
  before_action :set_events, only: [:new, :edit]
  before_action :set_month_allocations, only: [:index, :export]

  # GET /allocations
  # GET /allocations.json
  def index
    if params[:allocation].present?
      @allocation = Allocation.find(params[:allocation])
      # Check if allocation type is associate in charge first.
      # Next, heck if the availability date and allocation date matches.
      # Then check whether the availability start time is less than the allocation start time.
      # Finally check whether the availability end time is greater than the allocation end time.
      # If all conditions are met, the user is available for the assignment.
      if @allocation.consultant?
        @users = User.with_role(:consultant, @company)
      else
        @users = User.with_role(:associate, @company)
      end
      @users = @users.joins(:availabilities).where(availabilities: {available_date: @allocation.allocation_date}).where("availabilities.start_time <= ?", @allocation.start_time).where("availabilities.end_time >= ?", @allocation.end_time)
    else
      @allocation = Allocation.none
      @users = User.none
    end
  end

  # GET /allocations/1
  # GET /allocations/1.json
  def show
  end

  # GET /allocations/new
  def new
    @allocation = Allocation.new
  end

  # GET /allocations/1/edit
  def edit
  end

  # POST /allocations
  # POST /allocations.json
  def create
    @allocation = Allocation.new(allocation_params)

    respond_to do |format|
      if @allocation.save
        format.html { redirect_to conductor_allocations_path, notice: 'Allocation was successfully created.' }
        format.json { render :show, status: :created, location: @allocation }
      else
        set_associate
        set_events
        format.html { render :new }
        format.json { render json: @allocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /allocations/1
  # PATCH/PUT /allocations/1.json
  def update
    if allocation_params[:user_id].present?
      # If user id present, user is being assigned
      @availability = User.find(allocation_params[:user_id]).get_availability(@allocation)
      @availability.allocations<<(@allocation)
    else
      # If user id not present, user is being unassigned
      @availability = @allocation.user.get_availability(@allocation) if @allocation.user
      @availability.allocations.delete(@allocation)
    end

    respond_to do |format|
      if @availability and @availability.toggle!(:assigned) and @allocation.update(allocation_params)
        format.html { redirect_to conductor_allocations_path, notice: 'Allocation was successfully updated.' }
        format.json { render :show, status: :ok, location: @allocation }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        set_associate
        set_events
        @allocation.errors.add(:user, "not availabile for assignment") if @availability.blank?
        format.html { render :edit }
        format.json { render json: @allocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allocations/1
  # DELETE /allocations/1.json
  def destroy
    @allocation.destroy
    respond_to do |format|
      format.html { redirect_to conductor_allocations_path, notice: 'Allocation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export
    send_data @allocations.to_csv, filename: "Allocations_#{@date_from}_to_#{@date_to}.csv"
  end

  def last_minute
    @action = Allocation.find(params[:id])

    respond_to do |format|
      if @action.update_attributes(last_minute: !@action.last_minute)
        format.json { render json: @action.last_minute, status: :ok }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  def user_allocations
    @user = User.find(params[:user_id])
  end

  private

  def set_allocation
    @allocation = Allocation.find(params[:id])
  end

  def set_month_allocations
    @date_from = params[:start_date] ? params[:start_date].to_date.beginning_of_month : Date.current.beginning_of_month
    @date_to = @date_from.end_of_month
    @allocations = Allocation.where(allocation_date: @date_from..@date_to).joins(:event).where(events: { company_id: @company.id } ).order(allocation_date: :desc, start_time: :asc, id: :asc)
  end

  def set_company
    @company = current_user.company
  end

  def set_associate
    @users = User.where(company: @company).with_role :associate, @company
  end

  def set_events
    @events = Event.where(company: @company)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def allocation_params
    params.require(:allocation).permit(:user_id, :event_id, :allocation_date, :start_time, :end_time, :allocation_type, :last_minute, :rate)
  end
end