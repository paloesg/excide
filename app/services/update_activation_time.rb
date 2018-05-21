class UpdateActivationTime

  def initialize(activation, new_start_time, new_end_time)
    @activation     = activation
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
  end

  def run
    begin
      @activation.transaction do
        update_activation
        update_allocations
      end
      send_email_to_contractor
      return {success: true, contractors_status: contractors_status}
    rescue ActiveRecord::RecordInvalid
      return {success: false, errors: 'Error update activation time.'}
    end
  end

  private

  def update_activation
    @activation.update_attributes!(start_time: @new_start_time, end_time: @new_end_time)
  end

  def update_allocations
    @activation.allocations.each do |allocation|
      allocation.update_attributes!(allocation_date: @new_start_time, start_time: @new_start_time, end_time: @new_end_time)
    end
  end

  def check_contractor_availability(allocation)
    allocation.user.availabilities.where(available_date: allocation.allocation_date).where("start_time <= ?", @new_start_time).where("end_time >= ?", @new_end_time).present?
  end

  def send_email_to_contractor
    @activation.allocations.each do |allocation|
      next if allocation.user.blank?
      if check_contractor_availability(allocation)
        NotificationMailer.edit_activation(@activation, allocation.user).deliver
      else
        NotificationMailer.user_removed_from_activation(@activation, allocation.user).deliver
      end
    end
  end

  def contractors_status
    @contractors = { "update_time" => [], "unassigned" => [] }
    @activation.allocations.each do |allocation|
      next if allocation.user.blank?
      if check_contractor_availability(allocation)
        @contractors['update_time'] << allocation.user
      else
        @contractors['unassigned'] << allocation.user
        allocation.update_attribute(:user_id, nil)
      end
    end
    @contractors
  end

end