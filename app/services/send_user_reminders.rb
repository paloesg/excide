class SendUserReminders
  include Service

  def initialize(user)
    @user = user
  end

  def run
    get_user_reminders
    return OpenStruct.new(success?:true, reminder_count: 0, user: @user, message: 'No reminders for this user.') if @reminders.empty?
    send_email_reminders
    send_sms_reminders
    send_slack_reminders
    set_next_reminder
    return OpenStruct.new(success?:true, reminder_count: @reminders.count, user: @user, message: 'Reminders for this user sent.')
  end

  private

  def get_user_reminders
    @reminders = Reminder.today.where(user: @user)
  end

  def send_email_reminders
    email_reminders = @reminders.where(email: true)

    NotificationMailer.batch_reminder(email_reminders, @user).deliver_now
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
    to_number = '+65' + reminder.user.contact_number
    message_body = reminder.content

    @client = Twilio::REST::Client.new account_sid, auth_token

    message = @client.api.account.messages.create( from: from_number, to: to_number, body: message_body )
  end

  def send_slack_reminders
    slack_reminders = @reminders.where(slack: true)

    SlackService.new.send_reminders(slack_reminders).deliver
  end

  def set_next_reminder

  end
end