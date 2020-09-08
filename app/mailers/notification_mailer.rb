class NotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'
  require 'sendgrid-ruby'
  include SendGrid
  
  def batch_reminder(reminders, user)
    @reminders = reminders
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name
    mail(to: address.format, subject: 'Here are your reminders for today')
  end

  def daily_summary(email_summary_notifications, user, companies)
    @email_summary_notifications = email_summary_notifications
    @user = user
    @companies = companies
    # address = Mail::Address.new @user.email
    # address.display_name = @user.first_name
    mail(to: 'jonathan.lau@paloe.com.sg', from: 'Excide Symphony <admin@excide.co>', subject: 'Here is your daily email summary', body: 'Some body',  template_id: 'd-eb0e5c0edd7342529057a9058214a827', dynamic_template_data: {
        firstName: @user.first_name
      }
    )
  end

  def create_event(event, user)
    event_notification(event, user, 'A new event has been created')
  end

  def edit_event(event, user)
    event_notification(event, user, 'An event has been changed')
  end

  def destroy_event(event, user)
    event_notification(event, user, 'An event has been cancelled')
  end

  def user_removed_from_event(event, user)
    event_notification(event, user, "Unassigned: #{event.name} #{event.start_time.strftime("%F")} #{event.start_time.strftime("%H:%M")} - #{event.end_time.strftime("%H:%M")}")
  end

  def event_notification(event, user, subject)
    @user = user
    @subject = subject
    @event = event
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    mail(to: address.format, subject: @subject)
  end

  def associate_notification(user)
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    mail(to: address.format, subject: 'Assign your availability for the next month')
  end

  def free_trial_ending_notification(user)
    @user = user
    mail(to: @user.email, subject: '[Free trial ending]')
  end
end
