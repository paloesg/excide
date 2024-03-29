class SendUserReminders
  include Service
  include Rails.application.routes.url_helpers

  def initialize(user)
    @user = user
    @from_number = ENV['TWILIO_NUMBER']
    @account_sid = ENV['TWILIO_ACCOUNT_SID']
    @auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new @account_sid, @auth_token
  end

  def run
    get_user_reminders
    return OpenStruct.new(success?:true, reminder_count: 0, user: @user, message: 'No reminders for this user.') if @reminders.empty?
    send_email_reminders
    send_sms_reminders unless @user.company.basic?
    send_whatsapp_reminders unless @user.company.basic?
    send_slack_reminders unless @user.company.basic?
    set_next_reminder
    return OpenStruct.new(success?:true, reminder_count: @reminders.count, user: @user, message: 'Reminders for this user sent.')
  end

  private

  def get_user_reminders
    @reminders = Reminder.today.where(user: @user)
  end

  def send_email_reminders
    email_reminders = @reminders.where(email: true)
    # email_reminders[0]&.notify :users, key: "reminder.send_reminder", parameters: { reminders: email_reminders }, send_later: false
    # Initialize an array to push reminders into, and send to sendgrid email template
    @reminder_details = []
    email_reminders.each do |reminder|
      @reminder_details << {
        title: reminder.title,
        content: reminder.content,
        link_address: "#{ENV['ASSET_HOST'] + symphony_workflow_path(reminder.task.section.template.slug, reminder.workflow_action.workflow.friendly_id) }"
      }.as_json
    end
    NotificationMailer.batch_reminder(@reminder_details, @user).deliver_now if @user.settings[0]&.reminder_email == 'true'
  end

  def send_sms_reminders
    sms_reminders = @reminders.where(sms: true)

    sms_reminders.each do |reminder|
      send_sms(reminder)
    end
  end

  def send_whatsapp_reminders
    whatsapp_reminders = @reminders.where(sms: true)

    whatsapp_reminders.each do |reminder|
      send_whatsapp(reminder)
    end
  end

  def send_sms(reminder)
    to_number = '+65' + reminder.user.contact_number
    message_body = reminder.content

    message = @client.api.account.messages.create( from: @from_number, to: to_number, body: message_body ) if @user.settings[0]&.reminder_sms == 'true'
  end

  def send_whatsapp(reminder)
    to_number = '+65' + reminder.user.contact_number
    message_body = reminder.content

    message = @client.messages.create( from: 'whatsapp:'+@from_number, to: 'whatsapp:'+to_number, body: message_body ) if @user.settings[0]&.reminder_whatsapp == 'true'
  end

  def send_slack_reminders
    slack_reminders = @reminders.where(slack: true)
    # check whether company is connected to slack or user's reminder setting is true. If it is not, don't send reminders.
    SlackService.new(@user).send_reminders(slack_reminders, @user).deliver if (@user.settings[0]&.reminder_slack == 'true' and @user.company.slack_access_response.present?)
  end

  def set_next_reminder
    @reminders.each do |reminder|
      deadline = reminder.task_id ? WorkflowAction.find_by(task_id: reminder.task_id).deadline : nil
      # check if before deadline reminder is present, reminder is from workflow action (i.e. task_id is present) and compare current date to deadline to set next reminder
      if @user.company.before_deadline_reminder_days.present? && deadline && (Date.current < deadline)
        day = deadline
      else
        day = Date.current + 1.day
      end
      reminder.next_reminder = day.on_weekday? ? day : day.next_weekday
      reminder.save
    end
  end
end
