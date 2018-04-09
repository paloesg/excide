class Availability < ActiveRecord::Base
  belongs_to :user

  validates :available_date, :start_time, :end_time, presence: true
  validate :end_must_be_after_start

  private

  def end_must_be_after_start
    if start_time >= end_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
