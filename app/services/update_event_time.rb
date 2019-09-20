class UpdateEventTime

  def initialize(event, new_start_time, new_end_time)
    @event     = event
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
    @associates_updated = 0
    @associates_unassigned = 0
  end

  def run
    if time_change?
      begin
        @event.transaction do
          update_event
          @event.allocations.each do |allocation|
            old_allocation, allocation = update_allocation(allocation)
            next if allocation.user.blank?
            if associate_available?(allocation)
              notify_associate(allocation)
            else
              remove_associate(allocation, old_allocation)
            end
          end
        end
        OpenStruct.new(success?: true, event: @event, message: success_message)
      rescue ActiveRecord::RecordInvalid
        OpenStruct.new(success?: false, event: @event)
      end
    else
      OpenStruct.new(success?:true, event: @event, message: 'No time change. ')
    end
  end

  private

  def time_change?
    if @event.start_time.zone.to_time == @new_start_time.zone.to_time and @event.end_time.zone.to_time == @new_end_time.zone.to_time
      false
    else
      true
    end
  end

  def update_event
    @event.update_attributes!(start_time: @new_start_time, end_time: @new_end_time)
  end

  def update_allocation(allocation)
    old_allocation = allocation.dup
    allocation.update_attributes!(allocation_date: @new_start_time, start_time: @new_start_time, end_time: @new_end_time)
    return old_allocation, allocation
  end

  def associate_available?(allocation)
    allocation.user.availabilities.where(available_date: allocation.allocation_date).where("start_time <= ?", @new_start_time).where("end_time >= ?", @new_end_time).present?
  end

  def notify_associate(allocation)
    NotificationMailer.edit_event(@event, allocation.user).deliver_later
    @associates_updated += 1
  end

  def remove_associate(allocation, old_allocation)
    removed_user = allocation.user
    allocation.update_attributes!(user_id: nil)
    removed_user.get_availability(old_allocation).toggle!(:assigned)
    NotificationMailer.user_removed_from_event(@event, removed_user).deliver_later
    @associates_unassigned += 1
  end

  def success_message
    message = ''
    (message += "#{@associates_updated} associate(s) informed of the new event time. ") if @associates_updated > 0
    (message += "#{@associates_unassigned} associate(s) unassigned from the event due to the time change. ") if @associates_unassigned > 0
    return message
  end
end