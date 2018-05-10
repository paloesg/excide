require 'csv'

class Allocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :activation

  enum allocation_type: [:contractor, :contractor_in_charge]

  validates :activation, :allocation_type, :allocation_date, :start_time, :end_time, presence: true
  validate :end_must_be_after_start

  def self.to_csv
    attributes = ['Activation', 'Allocation date', 'Start time', 'End time', 'User', 'Last Minute']

    CSV.generate do |csv|
      csv << attributes
      all.each do |allocation|
        row = [
          allocation.activation.name,
          allocation.allocation_date,
          allocation.start_time.in_time_zone.strftime("%H:%M"),
          allocation.end_time.in_time_zone.strftime("%H:%M"),
          allocation.user&.full_name,
          allocation.last_minute
        ]
        csv << row
      end
    end
  end

  def hours
    (self.end_time - self.start_time) / 3600
  end

  private

  def end_must_be_after_start
    # Skip this validation if start and end time not present to prevent errors
    return if start_time.blank? or end_time.blank?

    if end_time < start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
