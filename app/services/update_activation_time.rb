class UpdateActivationTime

  def initialize(activation, new_start_time, new_end_time)
    @activation     = activation
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
    @contractors_updated = 0
    @contractors_unassigned = 0
  end

  def run
    if time_change?
      begin
        @activation.transaction do
          update_activation
          @activation.allocations.each do |allocation|
            old_allocation, allocation = update_allocation(allocation)
            next if allocation.user.blank?
            if contractor_available?(allocation)
              notify_contractor(allocation)
            else
              remove_contractor(allocation, old_allocation)
            end
          end
        end
        OpenStruct.new(success?: true, activation: @activation, message: success_message)
      rescue ActiveRecord::RecordInvalid
        OpenStruct.new(success?: false, activation: @activation)
      end
    else
      OpenStruct.new(success?:true, activation: @activation, message: 'No time change. ')
    end
  end

  private

  def time_change?
    if @activation.start_time.to_time == @new_start_time.to_time and @activation.end_time.to_time == @new_end_time.to_time
      false
    else
      true
    end
  end

  def update_activation
    @activation.update_attributes!(start_time: @new_start_time, end_time: @new_end_time)
  end

  def update_allocation(allocation)
    old_allocation = allocation.dup
    allocation.update_attributes!(allocation_date: @new_start_time, start_time: @new_start_time, end_time: @new_end_time)
    return old_allocation, allocation
  end

  def contractor_available?(allocation)
    allocation.user.availabilities.where(available_date: allocation.allocation_date).where("start_time <= ?", @new_start_time).where("end_time >= ?", @new_end_time).present?
  end

  def notify_contractor(allocation)
    EmailJob.perform_async(NotificationMailer.edit_activation(@activation, allocation.user).deliver)
    @contractors_updated += 1
  end

  def remove_contractor(allocation, old_allocation)
    removed_user = allocation.user
    allocation.update_attributes!(user_id: nil)
    removed_user.get_availability(old_allocation).toggle!(:assigned)
    EmailJob.perform_async(NotificationMailer.user_removed_from_activation(@activation, removed_user).deliver)
    @contractors_unassigned += 1
  end

  def success_message
    message = ''
    (message += "#{@contractors_updated} contractor(s) informed of the new activation time. ") if @contractors_updated > 0
    (message += "#{@contractors_unassigned} contractor(s) unassigned from the activation due to the time change. ") if @contractors_unassigned > 0
    return message
  end
end