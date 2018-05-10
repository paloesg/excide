class UpdateActivationTime
  include Service

  def self.time_changed(params, activation)
    if params[:start_time] != activation.start_time.strftime("%F %H:%M") || params[:end_time] != activation.end_time.strftime("%F %H:%M")
      UpdateAllocationTime.new.update_time(params[:start_time], params[:end_time], activation)
    end
  end
  
end