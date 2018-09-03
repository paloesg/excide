require 'csv'

class Allocation < ApplicationRecord
  belongs_to :user
  belongs_to :activation

  enum allocation_type: [:contractor, :contractor_in_charge]

  monetize :rate_cents, allow_nil: true

  validates :activation, :allocation_type, :allocation_date, :start_time, :end_time, presence: true
  validate :end_must_be_after_start

  def self.to_csv
    attributes = ['S. S/N', 'Full Name', 'Date', 'Business unit', 'Department & location', 'Start', 'End', 'Type', 'Last Min / Replacement', 'Change Rate']

    CSV.generate do |csv|
      csv << attributes
      rowcount = 0
      all.each do |allocation|
        if allocation.user.present?
          row = [
            rowcount += 1,
            allocation.user&.full_name,
            allocation.allocation_date.strftime('%v'),
            allocation.activation.activation_type.name,
            allocation.activation.client&.name + " - " + allocation.activation.location,
            allocation.start_time.in_time_zone.strftime("%H:%M"),
            allocation.end_time.in_time_zone.strftime("%H:%M"),
            allocation.allocation_type.titleize,
            allocation.rate,
            allocation.last_minute ? "Yes" : "No"
          ]
          csv << row
        end
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
