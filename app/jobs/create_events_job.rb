class CreateEventsJob < ApplicationJob
  include SuckerPunch::Job
  include ApplicationHelper
  queue_as :default

  def perform(user, data)
    data.each do |row|
      # create hash from headers and cells
      @event = Event.new
      @event.company = user.company
      @department = user.department
      @event.categories << Category.find_or_create_by(name: titleize_keep_uppercase(row[:client]), category_type: "client") {|c| c.update(department: @department)} if row[:client].present?
      @event.categories << Category.find_or_create_by(name: titleize_keep_uppercase(row[:service_line]), category_type: "service_line") {|c| c.update(department: @department)} if row[:service_line].present?
      @event.categories << Category.find_or_create_by(name: titleize_keep_uppercase(row[:project]), category_type: "project") {|c| c.update(department: @department)} if row[:project].present?
      @event.categories << Category.find_or_create_by(name: titleize_keep_uppercase(row[:task]), category_type: "task") {|c| c.update(department: @department)} if row[:task].present?
      @event.start_time = row[:date]
      @event.number_of_hours = row[:hours]
      @event.save!
      GenerateTimesheetAllocationService.new(@event, user).run
    end
  end
end
