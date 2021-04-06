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
    mail(to: user.email, from: 'Asiawide ADA <support@paloe.com.sg>', subject: 'Here is your daily email summary', body: 'Some body',  template_id: ENV['SENDGRID_DAILY_SUMMARY_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
        actions: action_details,
        task_count: action_details.count,
        notification_setting_url: link
      }
    )
  end

  def overture_notification(user, profile)
    mail(to: "enquiry@paloe.com.sg", from: 'Paloe Overture <support@paloe.com.sg>', subject: 'TO SAM!', body: 'Some body',  template_id: ENV['SENDGRID_OVERTURE_STATED_INTEREST'], dynamic_template_data: {
        fullName: user.full_name,
        email: user.email,
        contactNumber: user.contact_number,
        profileName: profile.name,
        url: profile.url,
      }
    )
  end

  def motif_notify_franchisor(franchisor, user, wfa, link)
    mail(to: franchisor.email, from: 'Asiawide Digital Support <support@asiawidedigital.com>', subject: '', body: 'Some body',  template_id: ENV['ADA_SENDGRID_NOTIFY_FRANCHISOR'], dynamic_template_data: {
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
    mail(to: user.email, from: 'Asiawide Digital Support <support@asiawidedigital.com>', subject: '', body: 'Some body',  template_id: ENV['ADA_SENDGRID_FRANCHISEE_RENEWAL_NOTICE'], dynamic_template_data: {
        franchisee_name: franchisee.franchise_licensee,
        franchisee_expiry_date: franchisee.expiry_date,
        user_fullname: user.full_name,
        user_email: user.email,
      }
    )
  end

  def motif_new_outlet(user, outlet_details)
    #to email will be changed with afc's support email
    mail(to: ['jonathan.lau@paloe.com.sg', 'kristian.hadinata@paloe.com.sg', 'hansheng@paloe.com.sg'], from: 'Asiawide Digital Support <support@asiawidedigital.com>', subject: 'New Outlet', body: 'New outlet', template_id: ENV['ADA_SENDGRID_MOTIF_NEW_OUTLET'], dynamic_template_data: {
        fullName: user.full_name,
        company: user.company.name,
        email: user.email,
        outletUserName: outlet_details[:full_name],
        outletUserEmail: outlet_details[:email],
        outletName: outlet_details[:unit_name],
        request_approved: outlet_details[:request_approved].present? ? "Yes" : "No"
      }
    )
  end

  def motif_new_franchisee(user, franchisee_details)
    #to email will be changed with afc's support email
    mail(to: ['jonathan.lau@paloe.com.sg', 'kristian.hadinata@paloe.com.sg', 'hansheng@paloe.com.sg'], from: 'Asiawide Digital Support <support@asiawidedigital.com>', subject: 'New Franchisee', body: 'New franchisee', template_id: ENV['ADA_SENDGRID_MOTIF_NEW_FRANCHISEE'], dynamic_template_data: {
        fullName: user.full_name,
        company: user.company.name,
        email: user.email,
        franchiseeUserName: franchisee_details[:full_name],
        franchiseeUserEmail: franchisee_details[:email],
        franchiseeUnitName: franchisee_details[:unit_name],
        franchiseeType: franchisee_details[:license_type].titleize
      }
    )
  end

  # Conductor's email notification methods!
  # Most of the removed mailer methods below were called in event.rb. associate_notification was called in scehduler.rake as a daily reminder to associate.
  # Removed conductor's create_event, edit_event, destroy_event, user_removed_from_event, event_notification and associate_notification methods from the following PR:
  #
end
