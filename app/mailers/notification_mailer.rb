class NotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'
  require 'sendgrid-ruby'
  include SendGrid
  
  def batch_reminder(reminders, user)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: 'Here is your daily email summary', body: 'Some body',  template_id: ENV['SENDGRID_BATCH_REMINDER_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
        reminders: reminders,
        reminder_count: reminders.count
      }
    )
  end

  def daily_summary(action_details, user, link)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: 'Here is your daily email summary', body: 'Some body',  template_id: ENV['SENDGRID_DAILY_SUMMARY_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
        actions: action_details,
        task_count: action_details.count,
        notification_setting_url: link
      }
    )
  end

  def overture_notification(user, profile)
    mail(to: "sam@paloe.com.sg", from: 'Paloe Overture <admin@excide.co>', subject: 'TO SAM!', body: 'Some body',  template_id: ENV['SENDGRID_OVERTURE_STATED_INTEREST'], dynamic_template_data: {
        fullName: user.full_name,
        email: user.email,
        profileName: profile.name,
        url: profile.url, 
      }
    )
  end
  
  # Conductor's email notification methods!
  # Most of the removed mailer methods below were called in event.rb. associate_notification was called in scehduler.rake as a daily reminder to associate.
  # Removed conductor's create_event, edit_event, destroy_event, user_removed_from_event, event_notification and associate_notification methods from the following PR:
  #
end
