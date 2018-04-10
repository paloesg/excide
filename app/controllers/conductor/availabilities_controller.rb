class Conductor::AvailabilitiesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_availability, only: [:show, :edit, :update, :destroy]
  before_action :set_contractor, only: [:index, :new, :edit]

  # GET /availabilities
  # GET /availabilities.json
  def index
    @availabilities = Availability.all
  end

  # GET /availabilities/1
  # GET /availabilities/1.json
  def show
  end

  # GET /availabilities/new
  def new
    @times_header = [ "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM" ]
    @times_value = [ "09:00:00", "10:00:00", "11:00:00", "12:00:00", "13:00:00", "14:00:00", "15:00:00", "16:00:00", "17:00:00"]
    @availability = Availability.new
    if current_user.has_role? :contractor, :any
      @availability.user_id = current_user.id
      @disable_user_select = true
    else
      @availability.user_id ||= params[:user_id]
      @disable_user_select = false
    end
  end

  # GET /availabilities/1/edit
  def edit
  end

  # POST /availabilities
  # POST /availabilities.json
  def create
    # params[:available] format:
    # {"user_id"=>"52", "dates"=>{"2018-04-10"=>{"time"=>["09:00:00", "10:00:00", "11:00:00", "12:00:00", "13:00:00", "14:00:00", "15:00:00", "16:00:00", "17:00:00"]}, "2018-04-12"=>{"time"=>["10:00:00", "11:00:00", "12:00:00"]}, "2018-04-13"=>{"time"=>["14:00:00", "15:00:00", "16:00:00"]}}}
    available = params[:available]
    available_dates = []
    user_id = available[:user_id] || current_user
    available[:dates].each do |date|
      slice_time = date[1][:time].slice_when{|first, second| first.to_i+1 != second.to_i }
      slice_time.each do |time|
        available_date = date[0]
        start_time = time.first
        end_time = (Time.parse(time.last) + 1.hours).strftime("%T")
        available_dates << Availability.new(user_id: user_id, available_date: available_date , start_time: start_time, end_time: end_time)
      end
    end if available[:dates].present?

    after_save_path = (current_user.has_role? :temp_staff, :any) ? conductor_user_path : conductor_availabilities_path
    respond_to do |format|
      if available_dates.each(&:save!) and available_dates.any?
        format.html { redirect_to after_save_path, notice: 'Availability was successfully created.' }
        format.json { render :show, status: :created, location: @availability }
      else
        set_contractor
        format.html { redirect_to :back }
        format.json { render json: available_dates.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /availabilities/1
  # PATCH/PUT /availabilities/1.json
  def update
    respond_to do |format|
      if @availability.update(availability_params)
        format.html { redirect_to conductor_availabilities_path, notice: 'Availability was successfully updated.' }
        format.json { render :show, status: :ok, location: @availability }
      else
        set_contractor
        format.html { render :edit }
        format.json { render json: @availability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /availabilities/1
  # DELETE /availabilities/1.json
  def destroy
    @availability.destroy
    respond_to do |format|
      format.html { redirect_to conductor_availabilities_path, notice: 'Availability was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def user
    @user = User.find_by(id: params[:user_id])
    @availabilities = @user.availabilities.order(available_date: :asc, start_time: :asc)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_availability
      @availability = Availability.find(params[:id])
    end

    def set_company
      @company = current_user.company
    end

    def set_contractor
      @users = User.where(company: @company).with_role :contractor, @company
    end

    def after_save_path
      (current_user.has_role? :contractor, :any) ? conductor_user_path : conductor_availabilities_path
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def availability_params
      params.require(:availability).permit(:user_id, :available_date, :start_time, :end_time, :assigned)
    end
end
