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

  acts_as_notifiable :users,
    # Notification targets as :targets is a necessary option
    # Set to notify to author and users commented to the article, except comment owner self
    targets: :custom_notification_targets,
    # Allow notification email
    email_allowed: true,
    # Path to move when the notification is opened by the target user
    # This is an optional configuration since activity_notification uses polymorphic_path as default
    notifiable_path: :reminder_notifiable_path

  def reminder_notifiable_path
    symphony_reminders_path
  end

  def custom_notification_targets(key)
    if key == 'reminder.send_reminder'
      [self.user]
    end
  end

  def overriding_notification_email_subject(target, key)
    "[Reminder] - #{target.notifications.last.notifiable.title} - #{target.notifications.last.notifiable.content}"    
  end

  def self.today
    return Reminder.where(next_reminder: Date.current.beginning_of_day..Date.current.end_of_day)
  end

  def at_least_one_notification_method
    unless self.email? || self.sms? || self.slack?
      errors[:base] << "This reminder must have at least one notification method."
    end
  end
end
