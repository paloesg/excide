require 'csv'

class Allocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :activation

  def self.to_csv
    attributes = ['Activation', 'Allocation date', 'Start time', 'End time', 'User']

    CSV.generate do |csv|
      csv << attributes
      all.each do |allocation|
        row = [
          allocation.activation.name,
          allocation.allocation_date,
          allocation.start_time.in_time_zone.strftime("%H:%M"),
          allocation.end_time.in_time_zone.strftime("%H:%M"),
          allocation.user&.full_name
        ]
        csv << row
      end
    end
  end

  def hours
    return (self.end_time - self.start_time) / 3600
  end

end
