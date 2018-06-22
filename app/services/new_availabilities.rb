class NewAvailabilities
  def initialize(current_user, available, current_date)
    @current_user = current_user
    @available = available
    @date_from = available[:start_date].present? ? available[:start_date].to_date.beginning_of_week : current_date.beginning_of_week
    @date_to = @date_from.end_of_week
  end

  def run
    set_user_id
    remove_unassigned_availabilities
    available_dates = get_new_availabilities
    remove_old_assigned_availabilities(available_dates)
    unique_new_availabilities(available_dates)
  end

  private

  def set_user_id
    if @current_user.has_role? :contractor, :any
      @user_id = @current_user.id
    else
      @user_id = @available[:user_id]
    end
  end

  def remove_unassigned_availabilities
    User.find(@user_id).availabilities.where(available_date: @date_from..@date_to).where('assigned != ?', true).destroy_all
  end

  # get new availabilities
  def get_new_availabilities
    available_dates = []
    @available[:dates]&.each do |date|
      slice_time = date[1][:time].slice_when{|first, second| first.to_i+1 != second.to_i }
      slice_time.each do |time|
        available_date = date[0]
        start_time = time.first
        end_time = (Time.parse(time.last) + 1.hour).strftime("%T")
        if allocation_by_day(available_date).present?
          # If user have allocations on that day, check if the allocations overlap with the new availability. If overlap, availability can be assigned.
          allocation_by_day(available_date).each do |allocation|
            available = check_availability_by_allocation(allocation, available_date, start_time, end_time)
            if available = true
              available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time, assign: true)
            else
              available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
            end
          end
        else
          # If user have no allocations on that day, can just add new availability.
          available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
        end
      end
    end
    return available_dates
  end

  # To check user have allocations on that day
  def allocation_by_day(available_date)
    Allocation.where(user_id: @user_id).where(allocation_date: available_date)
  end

  # Check availability by allocation
  def check_availability_by_allocation(allocation, available_date, start_time, end_time)
    allocation_start_time = allocation.start_time.strftime("%T")
    allocation_end_time = allocation.end_time.strftime("%T")
    if (allocation_start_time > start_time and allocation_start_time >= end_time) or (allocation_end_time <= start_time and allocation_end_time < end_time)
      available = false
    elsif allocation_start_time >= start_time and allocation_end_time <= end_time
      available = true unless allocation_start_time == start_time and allocation_end_time == end_time and Availability.where(user_id: @user_id, available_date: available_date, assigned: true, start_time: start_time, end_time: end_time).present?
    end
    return available
  end

  # remove all previous assigned availabilities from new assigned availabilities
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
    # subtract new availabilities from overlapping new availabilities
    new_availabilities = available_dates - get_overlapping(available_dates)
    # remove duplicate new availability
    new_availabilities.uniq {|e| [e[:available_date], e[:start_time], e[:end_time]]}
  end

  # get overlapping new availabilities from exist assigned availabilities
  def get_overlapping(available_dates)
    overlapping = []
    Availability.where(user_id: @user_id, assigned: true, available_date: @date_from..@date_to).each do |availability|
      available_dates.each do |new_availability|
        if !new_availability.assigned and new_availability.available_date == availability.available_date
          if new_availability.start_time <= availability.start_time and new_availability.end_time >= availability.end_time
            overlapping << new_availability
          elsif new_availability.start_time <= availability.start_time and new_availability.end_time > availability.start_time
            overlapping << new_availability
          elsif new_availability.start_time < availability.end_time and new_availability.end_time >= availability.end_time
            overlapping << new_availability
          end
        end
      end
    end
    overlapping
  end
end