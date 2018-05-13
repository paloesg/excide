class UpdateAllocationTime
  def initialize(activation, allocation, new_start_time, new_end_time)
    @activation     = activation
    @allocation     = allocation
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
  end

  def run
    inform_user if @allocation&.user.present?
    update_allocation
  end

  private

  def update_allocation
    @allocation.update_attributes!(allocation_date: @new_start_time, start_time: @new_start_time, end_time: @new_end_time)
  end

  def inform_user
    if @allocation.user.availabilities.where("start_time <= ?", @new_start_time).where("end_time >= ?", @new_end_time).present?
      NotificationMailer.edit_activation(@activation, @allocation.user).deliver
    else
      NotificationMailer.user_removed_from_activation(@activation, @allocation.user).deliver
      @allocation.update_attribute(:user_id, nil)
    end
  end
end