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
    begin
      @activation.transaction do
        @activation.update!(@params)
        @activation.allocations.update_all(allocation_date: @new_start_time, start_time: @new_start_time, end_time: @new_end_time)
      end
      update_allocations
    rescue ActiveRecord::StatementInvalid
    end
  end

  def update_allocations
    @activation.allocations.each do |allocation|
      UpdateAllocationTime.new(@activation, allocation, @new_start_time, @new_end_time).run if allocation.user
    end
  end
end