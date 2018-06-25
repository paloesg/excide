class NewAvailabilities
  def initialize(current_user, available, current_date)
    @current_user = current_user
    @available = available
    @date_from = available[:start_date].present? ? available[:start_date].to_date.beginning_of_week : current_date.beginning_of_week
    @date_to = @date_from.end_of_week
  end

  def run
    set_user_id
    current_availabilities = get_current_availabilities
    assigned_dates = collect_assigned_dates(current_availabilities)
    remove_unassigned_availabilities(current_availabilities, assigned_dates)
    get_new_availabilities
  end

  private

  def set_user_id
    if @current_user.has_role? :contractor, :any
      @user_id = @current_user.id
    else
      @user_id = @available[:user_id]
    end
  end

  # Remove availabilities if not assign and not on any availability assigned dates
  def remove_unassigned_availabilities(current_availabilities, assigned_dates)
    current_availabilities.where('assigned != ?', true).where.not(available_date: assigned_dates).destroy_all
  end

  # Collect the dates of assigned availabilities
  def collect_assigned_dates(current_availabilities)
    current_availabilities.where(assigned: true).map{|a| a[:available_date]}
  end

  # Get availabilities from depend by start date (in a week)
  def get_current_availabilities
    User.find(@user_id).availabilities.where(available_date: @date_from..@date_to)
  end

  # Get new availabilities from params `@available[:dates]`
  def get_new_availabilities
    new_availabilities = []
    @available[:dates]&.each do |date|
      slice_time = date[1][:time].slice_when{|first, second| first.to_i+1 != second.to_i }
      slice_time.each do |time|
        available_date = date[0]
        start_time = time.first
        end_time = (Time.parse(time.last) + 1.hour).strftime("%T")
        new_availabilities << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
      end
    end
    return new_availabilities
  end

end