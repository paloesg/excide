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
    mail(to: ['jonathan.lau@paloe.com.sg', 'kristian.hadinata@paloe.com.sg', 'hansheng@paloe.com.sg', "support@asiawidedigital.com"], from: 'Asiawide Digital Support <support@asiawidedigital.com>', subject: 'New Outlet', body: 'New outlet', template_id: ENV['ADA_SENDGRID_MOTIF_NEW_OUTLET'], dynamic_template_data: {
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
    mail(to: ['jonathan.lau@paloe.com.sg', 'kristian.hadinata@paloe.com.sg', 'hansheng@paloe.com.sg', "support@asiawidedigital.com"], from: 'Asiawide Digital Support <support@asiawidedigital.com>', subject: 'New Franchisee', body: 'New franchisee', template_id: ENV['ADA_SENDGRID_MOTIF_NEW_FRANCHISEE'], dynamic_template_data: {
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

  def registered_interest(contact, latest_register_interest)
    person_name = "#{latest_register_interest["title"]} #{latest_register_interest["first_name"]} #{latest_register_interest["last_name"]}"
    mobile_number = "#{latest_register_interest["mobile_country_code"]} #{latest_register_interest["mobile_number"]}"
    #to email will be changed with afc's support email
    mail(to: "ada@paloe.com.sg", from: 'Asiawide Digital Support <support@paloe.com.sg>', subject: 'New Registered Interest', body: 'New Registered Interest', template_id: ENV['ADA_REGISTERED_INTEREST'], dynamic_template_data: {
        franchise_name: contact.name,
        registered_interest_user: person_name,
        capital_available: latest_register_interest["capital_available"],
        mobile_number: mobile_number,
        email: latest_register_interest["email_address"],
        personal_email_address: latest_register_interest["personal_email_address"],
        company_website: latest_register_interest["company_website"],
        my_designation: latest_register_interest["my_designation"],
        interests: latest_register_interest["interests"].map(&:titleize).join(", "),
        others_reason: latest_register_interest["others_reason"],
        areas_of_interest: latest_register_interest["areas_of_interest"],
        city: latest_register_interest["city"],
        previous_franchise: latest_register_interest["previous_franchise"],
      }
    )
  end

  def check_potential_franchise(contact)
    #to email will be changed with afc's support email
    mail(to: "ada@paloe.com.sg", from: 'Asiawide Digital Support <support@paloe.com.sg>', subject: 'New interest to list franchise', body: 'New Registered Interest', template_id: ENV['ADA_LIST_FRANCHISE'], dynamic_template_data: {
        brand_name: contact.name,
        user_email: contact.created_by.email,
        industry: contact.industry,
        year_founded: contact.year_founded,
        country_of_origin: contact.country_of_origin,
        markets_available: contact.markets_available,
        franchise_fees: contact.franchise_fees,
        average_investment: contact.average_investment,
        royalty: contact.royalty,
        marketing_fees: contact.marketing_fees,
        renewal_fees: contact.renewal_fees,
        franchisor_tenure: contact.franchisor_tenure
      }
    )
  end

  # Conductor's email notification methods!
  # Most of the removed mailer methods below were called in event.rb. associate_notification was called in scehduler.rake as a daily reminder to associate.
  # Removed conductor's create_event, edit_event, destroy_event, user_removed_from_event, event_notification and associate_notification methods from the following PR:
  #
end
