class SendUserReminders
  include Service

  def initialize(user)
    @user = user
  end

  def run
    get_user_reminders
    return OpenStruct.new(success?:true, reminder_count: 0, user: @user, message: 'No reminders for this user.') if @reminders.empty?
    set_next_reminder
    return OpenStruct.new(success?:true, reminder_count: @reminders.count, user: @user, message: 'Reminders for this user sent.', email_status: send_email_reminders, slack_status: send_slack_reminders, sms_status: send_sms_reminders)
  end

  private

  def get_user_reminders
    @reminders = Reminder.today.where(user: @user)
  end

  def send_email_reminders
    email_reminders = @reminders.where(email: true)
    NotificationMailer.batch_reminder(email_reminders, @user).deliver_now if @user.settings[0]&.reminder_email == 'true'
  end

  def send_sms_reminders
    sms_reminders = @reminders.where(sms: true)

    sms_reminders.each do |reminder|
      send_sms(reminder)
    end
  end

  def send_sms(reminder)
    from_number = ENV['TWILIO_NUMBER']
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    to_number = '+6281260236554'
    message_body = reminder.content

    @client = Twilio::REST::Client.new account_sid, auth_token

    message = @client.api.account.messages.create( from: from_number, to: to_number, body: message_body ) if @user.settings[0]&.reminder_sms == 'true'
  end

  def send_slack_reminders
    slack_reminders = @reminders.where(slack: true)

    SlackService.new.send_reminders(slack_reminders, @user).deliver if @user.settings[0]&.reminder_slack == 'true'
  end

  def set_next_reminder
    @reminders.each do |reminder|
      day = Date.current + 1.day
      reminder.next_reminder = day.on_weekday? ? day : day.next_weekday
      reminder.save
    end
  end
end