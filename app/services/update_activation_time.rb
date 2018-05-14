class UpdateActivationTime
  include Service

  def initialize(activation, params)
    @activation     = activation
    @params         = params
    @new_start_time = params['start_time']
    @new_end_time   = params['end_time']
  end

  def run
    update_activation
  end

  private

  def update_activation
    @activation.transaction do
      @activation.update!(@params)
      update_allocations
    end
  end

  def update_allocations
    @activation.allocations.each do |allocation|
      UpdateAllocationTime.new(@activation, allocation, @new_start_time, @new_end_time).run
    end
  end

end