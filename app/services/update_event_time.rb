class UpdateEventTime

  def initialize(event, new_start_time, new_end_time, user)
    @event     = event
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
    @user = user
    @associates_updated = 0
    @associates_unassigned = 0
  end

  def run
    if time_change?
      begin
        @event.transaction do
          update_event
          @event.allocations.each do |allocation|
            # Update availability
            update_availability(allocation)
            # update allocation for the event
            allocation.user.blank? ? next : update_allocation(allocation)
          end
        end
        OpenStruct.new(success?: true, event: @event, message: 'Edited event successfully')
      rescue ActiveRecord::RecordInvalid
        OpenStruct.new(success?: false, event: @event)
      end
    else
      OpenStruct.new(success?:true, event: @event, message: 'No time change. ')
    end
  end

  private

  def time_change?
    if @event.start_time.in_time_zone == DateTime.parse(@new_start_time).in_time_zone and @event.end_time.in_time_zone == DateTime.parse(@new_end_time).in_time_zone
      false
    else
      true
    end
  end

  def update_event
    @event.update_attributes!(start_time: @new_start_time, end_time: @new_end_time)
  end

  def update_allocation(allocation)
    allocation.update_attributes!(allocation_date: @new_start_time, start_time: @new_start_time, end_time: @new_end_time, user_id: @user.id)
  end

  def update_availability(allocation)
    allocation.availability.update_attributes(available_date: @new_start_time, user_id: @user.id, start_time: @new_start_time, end_time: @new_end_time)
  end
end
