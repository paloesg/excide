#DEPRECATED, PLEASE REFER TO SEND_USER_REMINDERS.RB INSTEAD.
class SendReminder
  include Service

  def initialize(reminder)
    @reminder = reminder
    @from_number = ENV['TWILIO_NUMBER']
    @account_sid = ENV['TWILIO_ACCOUNT_SID']
    @auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new @account_sid, @auth_token
  end

  def run
    # TODO: Move into a background service
    begin
      send_email_reminder if @reminder.email?
      send_sms_reminder if @reminder.sms?
      send_slack_reminder if @reminder.slack?
      send_whatsapp_reminder if @reminder.whatsapp?
    rescue => e
      reminder_error_notification(e)
      set_reminder_tomorrow
    end
    # TODO: Log reminders sent
    set_next_reminder
  end

  private

  def send_slack_reminder
    SlackService.new.send_reminder(@reminder).deliver if @reminder.user.settings[0]&.reminder_slack == 'true'
  end

  def send_email_reminder
    NotificationMailer.reminder_notification(@reminder).deliver_later if @reminder.user.settings[0]&.reminder_email == 'true'
  end

  def send_sms_reminder
    to_number = '+65' + @reminder.user.contact_number
    message_body = @reminder.content

    message = @client.api.account.messages.create( from: @from_number, to: to_number, body: message_body ) if @user.settings[0]&.reminder_sms == 'true'
  end

  def send_whatsapp_reminder
    to_number = '+65' + @reminder.user.contact_number
    message_body = @reminder.content

    message = @client.messages.create( from: 'whatsapp:'+@from_number, to: 'whatsapp:'+to_number, body: message_body ) if @user.settings[0]&.reminder_whatsapp == 'true'
  end

  def reminder_error_notification(e)
    SlackService.new.send_reminder_error(@reminder, e).deliver
  end

  def set_next_reminder
    if @reminder.repeat?
      @reminder.next_reminder = check_week_day(Date.current + @reminder.freq_value.to_i.send(@reminder.freq_unit))
    else
      @reminder.next_reminder = nil
    end
    @reminder.save
  end

  def set_reminder_tomorrow
    @reminder.next_reminder = check_week_day(Date.current + 1.day)
    @reminder.save
  end

  def check_week_day(day)
    day.on_weekday? ? day : day.next_weekday
  end
end