class Conductor::AvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_availability, only: [:show, :edit, :update, :destroy]
  before_action :set_associate, only: [:index, :edit]
  before_action :set_time_header, only: [:new, :edit]

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
    user_id = (current_user.has_role? :associate, :any) ? current_user.id : params[:user_id]
    last_availability = Availability.where(user_id: user_id).order('available_date ASC').last

    if last_availability.present?
      @date_from = params[:start_date].present? ? params[:start_date].to_date.beginning_of_week : last_availability.available_date.next_week
      @date_to = @date_from.end_of_week
    else
      @date_from = Date.current.beginning_of_week
      @date_to = @date_from.end_of_week
    end
    @availabilities = Availability.where(user_id: user_id).where(available_date: @date_from..@date_to)
  end

  # GET /availabilities/1/edit
  def edit
    @date_from = params[:start_date].present? ? params[:start_date].to_date.beginning_of_week : @availability.available_date.beginning_of_week
    @date_to = @date_from.end_of_week
    @availabilities = Availability.where(user_id: @availability.user_id).where(available_date: @date_from..@date_to)
  end

  # POST /availabilities
  # POST /availabilities.json
  def create
    # params[:available] format:
    # {"user_id"=>"52", "dates"=>{"2018-04-10"=>{"time"=>["09:00:00", "10:00:00", "11:00:00", "12:00:00", "13:00:00", "14:00:00", "15:00:00", "16:00:00", "17:00:00"]}, "2018-04-12"=>{"time"=>["10:00:00", "11:00:00", "12:00:00"]}, "2018-04-13"=>{"time"=>["14:00:00", "15:00:00", "16:00:00"]}}}
    update_availabilities = UpdateAvailabilities.new(current_user, params[:available], Date.current).run
    respond_to do |format|
      if update_availabilities.success?
        format.html { redirect_to after_save_path, notice: update_availabilities.message }
        format.json { render :show, status: :created, location: @availability }
      else
        flash[:alert] = update_availabilities.message
        format.html { render :new }
        format.json { render json: new_available_dates.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /availabilities/1
  # PATCH/PUT /availabilities/1.json
  def update
    update_availabilities = UpdateAvailabilities.new(@availability.user, params[:available], @availability.available_date).run
    respond_to do |format|
      if update_availabilities.success?
        format.html { redirect_to after_save_path, notice: update_availabilities.message }
        format.json { render :show, status: :created, location: @availability }
      else
        flash[:alert] = update_availabilities.message
        format.html { render :edit }
        format.json { render json: new_available_dates.errors, status: :unprocessable_entity }
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
    @availabilities = @user.availabilities.order(:available_date, :start_time)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_availability
    @availability = Availability.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end

  def set_associate
    @users = User.with_role(:associate, @company).uniq
  end

  def set_time_header
    @time_headers = ['9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM' ]
    @time_values = ['09:00:00', '10:00:00', '11:00:00', '12:00:00', '13:00:00', '14:00:00', '15:00:00', '16:00:00', '17:00:00']
  end

  def after_save_path
    (current_user.has_role? :associate, :any) ? conductor_user_path(current_user) : conductor_availabilities_path
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def availability_params
    params.require(:availability).permit(:user_id, :available_date, :start_time, :end_time, :assigned)
  end
end