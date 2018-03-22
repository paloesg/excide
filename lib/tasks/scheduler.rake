namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on"

  task :daily_reminders => :environment do
    time = Benchmark.realtime {
      reminders = Reminder.today
      reminders.each do |reminder|
        # TODO: Move reminder logic into reminder model
        reminder.send_slack_reminder
        reminder.send_email_reminder
        reminder.set_next_reminder
      end
    }

    Snitcher.snitch(ENV['SNITCH_TOKEN'], message: "Finished in #{time.round(2)} seconds.")
  end

  task :enquiry_emails => :environment do
    enquiries = Enquiry.yesterday.where(responded: false)
    enquiries.each do |enquiry|
      # If enquiry came in from vfo or about page without contact info, they are interested in the financial model template
      if enquiry.contact.nil? && (enquiry.source == "vfo" || enquiry.source == "about")
        EnquiryMailer.template_enquiry(enquiry).deliver_now
      else
        EnquiryMailer.general_enquiry(enquiry).deliver_now
      end
      enquiry.update_attributes(responded: true)
      SlackService.new.auto_response(enquiry).deliver
    end
  end
end