require 'csv'

class Allocation < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :availability

  enum allocation_type: [:associate, :consultant]

  monetize :rate_cents, allow_nil: true

  validates :event, :allocation_type, :allocation_date, :start_time, :end_time, presence: true

  def self.to_csv
    attributes = ['S. S/N', 'Department', 'Name', 'Date', 'Client', 'Job Function', 'Project', 'Task', 'Hours']

    CSV.generate do |csv|
      csv << attributes
      rowcount = 0
      # if self is an array (a month's events), all.each loops through the array
      all.each do |allocation|
        if allocation.user.present?
          row = [
            rowcount += 1,
            allocation.user&.department&.name,
            allocation.user&.full_name,
            allocation.event&.start_time.strftime('%v'),
            allocation.event&.categories.find_by(category_type: "client")&.name,
            # Service line is job function
            allocation.event&.categories.find_by(category_type: "service_line")&.name,
            allocation.event&.categories.find_by(category_type: "project")&.name,
            # Event type is task
            allocation.event&.categories.find_by(category_type: "task")&.name,
            allocation.event.number_of_hours,  
          ]
          csv << row
        end
      end
    end
  end

  def hours
    (self.end_time - self.start_time) / 3600
  end
end
