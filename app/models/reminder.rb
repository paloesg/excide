class Reminder < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

  belongs_to :user
  belongs_to :company
  belongs_to :task
  belongs_to :company_action

  enum freq_unit: [:days, :weeks, :months, :years]

  validates :user, :company, presence: true
  validate :at_least_one_notification_method

  def self.today
    reminders = Reminder.where('DATE(next_reminder) = ?', Date.current)
  end

  def at_least_one_notification_method
    unless self.email? || self.sms? || self.slack?
      errors[:base] << "This reminder must have at least one notification method."
    end
  end
end
