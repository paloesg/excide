class Reminder < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

  belongs_to :user
  belongs_to :company
  belongs_to :task
  belongs_to :company_action

  enum freq_unit: [:days, :weeks, :months, :years]

  validate :at_least_one_notification_method

  def self.today
    reminders = Reminder.where('DATE(next_reminder) = ?', Date.today)
  end

  def send_reminder
    # TODO: Move into a background service
    send_email_reminder if self.email?
    send_sms_reminder if self.sms?
    send_slack_reminder if self.slack?
    # TODO: Log reminders sent
    set_next_reminder
  end

  def send_slack_reminder
    SlackService.new.send_reminder(self).deliver
  end

  def send_email_reminder
    NotificationMailer.reminder_notification(self).deliver_now
  end

  def send_sms_reminder
    from_number = ENV['TWILIO_NUMBER']
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    to_number = '+65' + self.user.contact_number
    message_body = self.content

    @client = Twilio::REST::Client.new account_sid, auth_token

    message = @client.api.account.messages.create( from: from_number, to: to_number, body: message_body )
  end

  def set_next_reminder
    if self.repeat?
      self.next_reminder = Date.today + self.freq_value.to_i.send(self.freq_unit)
    else
      self.next_reminder = nil
    end
    self.save
  end

  def at_least_one_notification_method
    unless self.email? || self.sms? || self.slack?
      errors[:base] << "This reminder must have at least one notification method."
    end
  end
end
