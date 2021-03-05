class UpdateEventTime

  def initialize(event, new_start_time, new_end_time, user, service_line)
    @event     = event
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
    @user = user
    @service_line = service_line
    @associates_updated = 0
    @associates_unassigned = 0
  end

  def run
    begin
      @event.transaction do
        update_event
        update_event_tag if @service_line.present?
        @event.allocations.each do |allocation|
          # Update availability
          update_availability(allocation)
          # update allocation for the event
          allocation.user.blank? ? next : update_allocation(allocation)
        end
      end
      OpenStruct.new(success?: true, event: @event)
    rescue ActiveRecord::RecordInvalid
      OpenStruct.new(success?: false, event: @event)
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
    @event.update!(start_time: @new_start_time, end_time: @new_end_time)
  end

  def update_event_tag
    # Remove all tags
    @event.service_lines = []
    # Add new updated tag
    @event.service_line_list.add(@service_line)
  end

  def update_allocation(allocation)
    allocation.update(allocation_date: @new_start_time, start_time: @new_start_time, end_time: @new_end_time, user_id: @user.id)
  end

  def update_availability(allocation)
    allocation.availability.update(available_date: @new_start_time, user_id: @user.id, start_time: @new_start_time, end_time: @new_end_time)
  end

  # Removed email notification:
  # notify_associate and remove_association
  # https://github.com/hschin/excide/pull/648

end
