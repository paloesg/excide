class UpdateActivationTime
  include Service

  def initialize(activation, new_start_time, new_end_time)
    @activation     = activation
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
    @users          = []
  end

  def run
    begin
      @activation.transaction do
        update_activation
        update_allocations
      end
      inform_user
    rescue ActiveRecord::StatementInvalid
    end
    return {activation: @activation, users: @users}
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

  def inform_user
    @users = UpdateAllocationTime.new(@activation, @new_start_time, @new_end_time).run
  end
end