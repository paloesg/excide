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
      send_email_activation_update
      return {success: true, contractors: @contractors}
    rescue ActiveRecord::RecordInvalid
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

  def send_email_activation_update
    @contractors = { "update_time" => 0, "unassigned" => 0 }

    @activation.allocations.each do |allocation|
      next if allocation.user.blank?
      if allocation.user.availabilities.where(available_date: allocation.allocation_date).where("start_time <= ?", @new_start_time).where("end_time >= ?", @new_end_time).present?
        NotificationMailer.edit_activation(@activation, allocation.user).deliver
        @contractors['update_time'] += 1
      else
        NotificationMailer.user_removed_from_activation(@activation, allocation.user).deliver
        allocation.update_attribute(:user_id, nil)
        @contractors['unassigned'] += 1
      end
    end
    @contractors
  end
end