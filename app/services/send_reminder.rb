class SendReminder
  include Service

  def initialize(reminder)
    @reminder = reminder
  end

  def run
    # TODO: Move into a background service
    send_email_reminder if @reminder.email?
    send_sms_reminder if @reminder.sms?
    send_slack_reminder if @reminder.slack?
    # TODO: Log reminders sent
    set_next_reminder
  end

  private

  def send_slack_reminder
    SlackService.new.send_reminder(@reminder).deliver
  end

  def send_email_reminder
    NotificationMailer.reminder_notification(@reminder).deliver_now
  end

  def send_sms_reminder
    from_number = ENV['TWILIO_NUMBER']
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    to_number = '+65' + @reminder.user.contact_number
    message_body = @reminder.content

    @client = Twilio::REST::Client.new account_sid, auth_token

    message = @client.api.account.messages.create( from: from_number, to: to_number, body: message_body )
  end

  def set_next_reminder
    if @reminder.repeat?
      @reminder.next_reminder = Date.current + @reminder.freq_value.to_i.send(@reminder.freq_unit)
    else
      @reminder.next_reminder = nil
    end
    @reminder.save
  end
end