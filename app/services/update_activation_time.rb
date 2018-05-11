class UpdateActivationTime
  include Service

  def initialize(activation, params)
    @activation     = activation
    @params         = params
    @new_start_time = params['start_time']
    @new_end_time   = params['end_time']
  end

  def run
    time_changed
  end

  private

  def time_changed
    @activation.transaction do
      @activation.allocations.transaction do
        @activation.allocations.update_all(allocation_date: @new_start_time, start_time: @new_start_time, end_time: @new_end_time)
        @activation.allocations.each do |allocation|
          UpdateAllocationTime.new.run(@activation, @allocation, @new_start_time, @new_end_time)
        end
        @activation.update(params)
      end
    end
  end

end