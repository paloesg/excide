class UpdateActivationTime

  def initialize(activation, new_start_time, new_end_time)
    @activation     = activation
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
  end

  def run
    begin
      @activation.transaction do
        @contractors_status = { "update_time" => [], "unassigned" => [] }
        update_activation
        @activation.allocations.each do |allocation|
          update_allocation(allocation)
          next if allocation.user.blank?
          if contractor_available?(allocation)
            notify_contractor(allocation)
          else
            remove_contractor(allocation)
          end
        end
      end
      return {success: true, contractors_status: @contractors_status}
    rescue ActiveRecord::RecordInvalid
      return {success: false, errors: 'Error updating activation time.'}
    end
  end

  private

  def update_activation
    @activation.update_attributes!(start_time: @new_start_time, end_time: @new_end_time)
  end

  def update_allocation(allocation)
    allocation.update_attributes!(allocation_date: @new_start_time, start_time: @new_start_time, end_time: @new_end_time)
  end

  def contractor_available?(allocation)
    allocation.user.availabilities.where(available_date: allocation.allocation_date).where("start_time <= ?", @new_start_time).where("end_time >= ?", @new_end_time).present?
  end

  def notify_contractor(allocation)
    NotificationMailer.edit_activation(@activation, allocation.user).deliver
    @contractors_status['update_time'] << allocation.user
  end

  def remove_contractor(allocation)
    removed_user = allocation.user
    allocation.update_attributes!(user_id: nil)
    removed_user.get_availability(allocation).toggle!(:assigned)
    NotificationMailer.user_removed_from_activation(@activation, removed_user).deliver
    @contractors_status['unassigned'] << removed_user
  end
end