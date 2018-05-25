class NewAvailabilities
  def initialize(current_user, available, date_from, date_to)
    @current_user = current_user
    @available = available
    @date_from = @date_from
    @date_to = @date_to
  end

  def run
    set_user_id
    destroy_before_update
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

  def destroy_before_update
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
            if allocation.start_time.strftime("%H:%M:%S") > start_time and allocation.start_time.strftime("%H:%M:%S") >= end_time
              available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
            elsif allocation.start_time.strftime("%H:%M:%S") > start_time and allocation.end_time.strftime("%H:%M:%S") == end_time
              available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
            elsif allocation.start_time.strftime("%H:%M:%S") > start_time and allocation.end_time.strftime("%H:%M:%S") < end_time
              available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
            elsif allocation.start_time.strftime("%H:%M:%S") == start_time and allocation.end_time.strftime("%H:%M:%S") < end_time
              available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
            elsif allocation.end_time.strftime("%H:%M:%S") <= start_time and allocation.end_time.strftime("%H:%M:%S") < end_time
              available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
            end
          end
        else
          available_dates << Availability.new(user_id: @user_id, available_date: available_date , start_time: start_time, end_time: end_time)
        end
      end
    end
    available_dates
  end

  def allocation_by_day(available_date)
    Allocation.where(user_id: @user_id).where(allocation_date: available_date)
  end
end