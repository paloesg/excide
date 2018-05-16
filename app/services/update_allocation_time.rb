class UpdateAllocationTime
  def initialize(activation, new_start_time, new_end_time)
    @activation     = activation
    @allocations    = activation.allocations
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
    @users          = { "update_time" => 0, "unassigned" => 0 }
  end

  def run
    return inform_user
  end

  private

  def inform_user
    @allocations.each do |allocation|
      if allocation.user.availabilities.where(available_date: allocation.allocation_date).where("start_time <= ?", @new_start_time).where("end_time >= ?", @new_end_time).present?
        NotificationMailer.edit_activation(@activation, allocation.user).deliver
        @users['update_time'] += 1
      else
        NotificationMailer.user_removed_from_activation(@activation, allocation.user).deliver
        allocation.update_attribute(:user_id, nil)
        @users['unassigned'] += 1
      end
    end
    @users
  end
end