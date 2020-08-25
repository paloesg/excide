class GenerateTimesheetAllocationService
  def initialize(event, user)
    @event = event
    @user = user
  end

  def run
    begin
      generate_availability
      generate_allocation
      OpenStruct.new(success?: true, availability: @availability, allocation: @allocation)
    rescue => e
      OpenStruct.new(success?: false, availability: @availability, allocation: @allocation, message: e.message)
    end
  end

  private
  def generate_availability
    # Generate availabilities when the associate/consultant records the timesheet themselves. Assigned will be automatically true
    @availability = Availability.new(user_id: @user.id, available_date: @event.start_time.to_date, start_time: @event.start_time.strftime("%H:%M"), end_time: (@event.start_time + 1.day).strftime("%H:%M"), assigned: true)
    @availability.save
  end

  def generate_allocation
    @allocation = Allocation.new(user_id: @user.id, event_id: @event.id, allocation_date: @event.start_time.to_date, start_time: @event.start_time.strftime("%H:%M"), end_time: (@event.start_time + 1.day).strftime("%H:%M"), allocation_type: (@user.has_role? :associate, @user.company) ? "associate" : "consultant", availability_id: @availability.id)
    @allocation.save
  end

end
