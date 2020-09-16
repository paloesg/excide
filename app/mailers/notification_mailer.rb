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

  def daily_summary(action_details, user)
    @action_details = action_details
    @user = user
    mail(to: @user.email, from: 'Paloe Symphony <admin@excide.co>', subject: 'Here is your daily email summary', body: 'Some body',  template_id: ENV['SENDGRID_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: @user.first_name,
        actions: @action_details,
        task_count: @action_details.count
      }
    )
  end
  
  # Conductor's email notification methods!
  # Most of the removed mailer methods below were called in event.rb. associate_notification was called in scehduler.rake as a daily reminder to associate.
  # Removed conductor's create_event, edit_event, destroy_event, user_removed_from_event, event_notification and associate_notification methods from the following PR:
  #

  def free_trial_ending_notification(user)
    @user = user
    mail(to: @user.email, subject: '[Free trial ending]')
  end
end
