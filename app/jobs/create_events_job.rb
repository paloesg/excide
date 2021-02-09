class CreateEventsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(user, data)
    data.each do |row|
      # create hash from headers and cells
      @event = Event.new
      @event.company = user.company
      @department = user.department
      @event.categories << Category.find_or_create_by(name: row[:client], category_type: "client", department: @department) if row[:client].present?
      @event.categories << Category.find_or_create_by(name: row[:service_line], category_type: "service_line", department: @department) if row[:service_line].present?
      @event.categories << Category.find_or_create_by(name: row[:project], category_type: "project", department: @department) if row[:project].present?
      @event.categories << Category.find_or_create_by(name: row[:task], category_type: "task", department: @department) if row[:task].present?
      @event.start_time = row[:date]
      @event.number_of_hours = row[:hours]
      @event.save!
      GenerateTimesheetAllocationService.new(@event, user).run
    end
  end
end
