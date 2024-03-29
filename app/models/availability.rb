class Availability < ApplicationRecord
  belongs_to :user
  has_many :allocations, after_add: :assign_status, after_remove: :assign_status

  validates :user, :available_date, :start_time, :end_time, presence: true
  validate :end_must_be_after_start

  def assign_status(_allocation)
    self.update_column(:assigned, self.allocations.present?)
  end

  def self.overlapping(user_id:, available_date:, start_time:, end_time:)
    self.where(user_id: user_id, available_date: available_date).where("start_time <= ?", end_time).where("end_time > ?", start_time).present?
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
