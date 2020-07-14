require 'csv'

class Allocation < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :availability

  enum allocation_type: [:associate, :consultant]

  monetize :rate_cents, allow_nil: true

  validates :event, :allocation_type, :allocation_date, :start_time, :end_time, presence: true
  validate :end_must_be_after_start

  def self.to_csv
    attributes = ['S. S/N', 'Full Name', 'Date', 'Hours Charged', 'Job Nature', 'Client', 'Service Line', 'Type', 'Start', 'End']

    CSV.generate do |csv|
      csv << attributes
      rowcount = 0
      all.each do |allocation|
        if allocation.user.present?
          row = [
            rowcount += 1,
            allocation.user&.full_name,
            allocation.allocation_date.strftime('%v'),
            # Find hours charged
            (allocation.end_time - allocation.start_time)/3600,
            allocation.event.event_type.name,
            allocation.event.client&.name,
            allocation.event.tag_list.present? ? allocation.event.tag_list.last : 'Nil',
            allocation.allocation_type.titleize,
            allocation.start_time.in_time_zone.strftime("%H:%M"),
            allocation.end_time.in_time_zone.strftime("%H:%M"),
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
