class UpdateActivationTime
  include Service

  def initialize(activation, new_start_time, new_end_time)
    @activation     = activation
    @new_start_time = new_start_time
    @new_end_time   = new_end_time
  end

  def run
    @activation.transaction do
      update_activation
      update_allocations
    end
  end

  private

  def update_activation
    @activation.update_attributes!(start_time: @new_start_time, end_time: @new_end_time)
  end

  def update_allocations
    @activation.allocations.each do |allocation|
      UpdateAllocationTime.new(@activation, allocation, @new_start_time, @new_end_time).run
    end
  end
end