require 'csv'

class Allocation < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :availability

  enum allocation_type: [:associate, :consultant]

  monetize :rate_cents, allow_nil: true

  validates :event, :allocation_type, :allocation_date, :start_time, :end_time, presence: true

  def self.to_csv
    attributes = ['S. S/N', 'Full Name', 'Date', 'Client', 'Service Line', 'Hours Charged', 'Job Nature']

    CSV.generate do |csv|
      csv << attributes
      rowcount = 0
      all.each do |allocation|
        if allocation.user.present?
          row = [
            rowcount += 1,
            allocation.user&.full_name,
            allocation.allocation_date.strftime('%v'),
            allocation.event.client&.name,
            allocation.event.event_type.name,
            # Find hours charged
            allocation.event.number_of_hours,
            allocation.event.tag_list.present? ? allocation.event.tag_list.last : 'Nil',    
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
