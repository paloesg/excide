class Availability < ActiveRecord::Base
  belongs_to :user

  validates :user, :available_date, :start_time, :end_time, presence: true
  validate :end_must_be_after_start

  private

  def end_must_be_after_start
    # Skip this validation if start and end time not present to prevent errors
    return if start_time.blank? or end_time.blank?

    if end_time < start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
