class NewAvailabilities
  def initialize(current_user, available)
    @current_user = current_user
    @available = available
    @date_from = available[:start_date].present? ? available[:start_date].to_date.beginning_of_week : Date.current.beginning_of_week
    @date_to = @date_from.end_of_week
  end

  def run
    set_user_id
    remove_unassigned_availabilities
    get_new_availabilities
  end

  private

  def set_user_id
    if @current_user.has_role? :contractor, :any
      @user_id = current_user.id
    else
      @user_id = @available[:user_id]
    end
  end

  def remove_unassigned_availabilities
    User.find(@user_id).availabilities.where(available_date: @date_from..@date_to).where('assigned != ?', true).destroy_all
  end

  def get_new_availabilities
    available_dates = []
    @available[:dates]&.each do |date|
      slice_time = date[1][:time].slice_when{|first, second| first.to_i+1 != second.to_i }
      slice_time.each do |time|
        available_date = date[0]
        start_time = time.first
        end_time = (Time.parse(time.last) + 1.hour).strftime("%T")
        if allocation_by_day(available_date).present?
          allocation_by_day(available_date).each do |allocation|
            checked_availability = check_availability_by_allocation(allocation, available_date, start_time, end_time)
            if checked_availability.present?
              available_dates << checked_availability
            end
          end
        else
          available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
        end
      end
    end
    remove_old_assigned_availabilities(available_dates)
    unique_new_availabilities(available_dates)
  end

  def allocation_by_day(available_date)
    Allocation.where(user_id: @user_id).where(allocation_date: available_date)
  end

  def check_availability_by_allocation(allocation, available_date, start_time, end_time)
    allocation_start_time = allocation.start_time.strftime("%T")
    allocation_end_time = allocation.end_time.strftime("%T")
    if allocation_start_time > start_time and allocation_start_time >= end_time
      new_availability_if_not_exist(available_date, start_time, end_time)
    elsif allocation_start_time > start_time and allocation_end_time == end_time
      Availability.new(user_id: @user_id, available_date: available_date, assigned: true, start_time: start_time, end_time: end_time)
    elsif allocation_start_time > start_time and allocation_end_time < end_time
      Availability.new(user_id: @user_id, available_date: available_date, assigned: true, start_time: start_time, end_time: end_time)
    elsif allocation_start_time == start_time and allocation_end_time < end_time
      Availability.new(user_id: @user_id, available_date: available_date, assigned: true, start_time: start_time, end_time: end_time)
    elsif allocation_start_time == start_time and allocation_end_time == end_time
      if Availability.where(user_id: @user_id, available_date: available_date, assigned: true, start_time: start_time, end_time: end_time).blank?
        Availability.new(user_id: @user_id, available_date: available_date, assigned: true, start_time: start_time, end_time: end_time)
      end
    elsif allocation_end_time <= start_time and allocation_end_time < end_time
      new_availability_if_not_exist(available_date, start_time, end_time)
    end
  end

  def new_availability_if_not_exist(available_date, start_time, end_time)
    if Availability.where(user_id: @user_id, available_date: available_date, start_time: start_time, end_time: end_time).blank? || Availability.where(user_id: @user_id, available_date: available_date, assigned: true).where('start_time <= ?', start_time).where('end_time >= ?', end_time).blank?
      Availability.new(user_id: @user_id, available_date: available_date, start_time: start_time, end_time: end_time)
    end
  end

  def remove_old_assigned_availabilities(available_dates)
    new_assigned_availabilities = available_dates.select{|a| a[:assigned] }
    new_assigned_availabilities.each do |availability|
      Availability.where(user_id: @user_id, available_date: availability[:available_date], assigned: true).where('start_time >= ?', availability[:start_time]).where('end_time <= ?', availability[:end_time]).destroy_all
      Availability.where(user_id: @user_id, available_date: availability[:available_date], assigned: true).where('start_time <= ?', availability[:start_time]).where('end_time >= ?', availability[:end_time]).destroy_all
    end
  end

  def unique_new_availabilities(available_dates)
    # sort assigned new availability
    available_dates.sort_by! {|k| k[:assigned] ? 0 : 1}
    # remove duplicate new availability
    available_dates.uniq {|e| [e[:available_date], e[:start_time], e[:end_time]]}
  end
end