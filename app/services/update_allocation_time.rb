class UpdateAllocationTime

  def update_time(start_time, end_time, activation)
    activation.allocations.update_all(allocation_date: start_time, start_time: start_time, end_time: end_time)
  end
  
end