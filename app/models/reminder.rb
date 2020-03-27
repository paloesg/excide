class Reminder < ApplicationRecord
  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller && controller.current_user },
          recipient: ->(_controller, model) { model&.user }

  belongs_to :user
  belongs_to :company
  belongs_to :task
  belongs_to :workflow_action

  enum freq_unit: [:days, :weeks, :months, :years]

  validates :user, :company, :title, presence: true
  validate :at_least_one_notification_method

  def self.today
    return Reminder.where(next_reminder: Date.current.beginning_of_day..Date.current.end_of_day)
  end

  def at_least_one_notification_method
    unless self.email? || self.sms? || self.slack?
      errors[:base] << "This reminder must have at least one notification method."
    end
  end
end
