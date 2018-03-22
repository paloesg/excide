class Reminder < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

  belongs_to :user
  belongs_to :company
  belongs_to :task
  belongs_to :company_action

  enum freq_unit: [:days, :weeks, :months, :years]

  def self.today
    reminders = Reminder.where('DATE(next_reminder) = ?', Date.today)
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
end
