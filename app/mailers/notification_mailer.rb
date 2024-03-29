class NotificationMailer < ApplicationMailer
  default from: 'Paloe <support@paloe.com.sg>'
  require 'sendgrid-ruby'
  include SendGrid

  def batch_reminder(reminders, user)
    mail(to: user.email, from: 'Paloe Symphony <support@paloe.com.sg>', subject: 'Here is your daily email summary', body: 'Some body',  template_id: ENV['SENDGRID_BATCH_REMINDER_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
        reminders: reminders,
        reminder_count: reminders.count
      }
    )
  end

  def daily_summary(action_details, user, link)
    mail(to: user.email, from: 'Paloe Symphony <support@paloe.com.sg>', subject: 'Here is your daily email summary', body: 'Some body',  template_id: ENV['SENDGRID_DAILY_SUMMARY_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
        actions: action_details,
        task_count: action_details.count,
        notification_setting_url: link
      }
    )
  end

  ###########################
  #                         #
  #   Motif Email Methods   #
  #                         #
  ###########################
  def motif_notify_franchisor(franchisor, user, wfa, link)
    mail(to: franchisor.email, from: 'Paloe ADA <support@paloe.com.sg>', subject: '', body: 'Some body',  template_id: ENV['ADA_SENDGRID_NOTIFY_FRANCHISOR'], dynamic_template_data: {
        franchisor_fullname: franchisor.full_name,
        franchisor_email: franchisor.email,
        user_fullname: user.full_name,
        user_email: user.email,
        link_address: link,
        wfa_task_instructions: wfa.task.instructions
      }
    )
  end

  def motif_renewal_notice_outlet(franchisee, user)
    mail(to: user.email, from: 'Paloe ADA <support@paloe.com.sg>', subject: '', body: 'Some body',  template_id: ENV['ADA_SENDGRID_FRANCHISEE_RENEWAL_NOTICE'], dynamic_template_data: {
        franchisee_name: franchisee.franchise_licensee,
        franchisee_expiry_date: franchisee.expiry_date,
        user_fullname: user.full_name,
        user_email: user.email,
      }
    )
  end

  ###########################
  #                         #
  #  Overture Email Methods #
  #                         #
  ###########################

  def overture_notification(user, profile)
    mail(to: "support@paloe.com.sg", from: 'Paloe Overture <support@paloe.com.sg>', subject: 'TO SAM!', body: 'Some body',  template_id: ENV['SENDGRID_OVERTURE_STATED_INTEREST'], dynamic_template_data: {
        fullName: user.full_name,
        email: user.email,
        contactNumber: user.contact_number,
        profileName: profile.name,
        url: profile.url,
      }
    )
  end

  def assign_to_question_notification(user, topic)
    mail(to: user.email, from: 'Paloe Overture <support@paloe.com.sg>', subject: 'TO SAM!', body: 'Some body',  template_id: ENV['OVERTURE_ASSIGN_QUESTION'], dynamic_template_data: {
        subject_topic: topic.subject_name,
      }
    )
  end

  def need_approval_notification(user, topic, note)
    mail(to: user.email, from: 'Paloe Overture <support@paloe.com.sg>', subject: 'TO SAM!', body: 'Some body',  template_id: ENV['OVERTURE_NEED_APPROVAL'], dynamic_template_data: {
        subject_topic: topic.subject_name,
        note_content: note.content,
        user_that_answered: note.user.full_name
      }
    )
  end

  # Conductor's email notification methods!
  # Most of the removed mailer methods below were called in event.rb. associate_notification was called in scehduler.rake as a daily reminder to associate.
  # Removed conductor's create_event, edit_event, destroy_event, user_removed_from_event, event_notification and associate_notification methods from the following PR:
  #
end
