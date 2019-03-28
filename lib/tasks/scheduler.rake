namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on"

  task :daily_reminders => :environment do
    time = Benchmark.realtime {
      User.all.each do |user|
        SendUserReminders.run(user)
      end
    }

    Snitcher.snitch(ENV['SNITCH_TOKEN'], message: "Finished in #{time.round(2)} seconds.")
  end

  task :enquiry_emails => :environment do
    enquiries = Enquiry.yesterday.where(responded: false)
    enquiries.each do |enquiry|
      # If enquiry came in from vfo or about page without contact info, they are interested in the financial model template
      if enquiry.contact.nil? && (enquiry.source == "vfo" || enquiry.source == "about")
        EnquiryMailer.template_enquiry(enquiry).deliver_later
      else
        EnquiryMailer.general_enquiry(enquiry).deliver_later
      end
      enquiry.update_attributes(responded: true)
      SlackService.new.auto_response(enquiry).deliver
    end
  end

  task :contractor_reminders => :environment do
    users = User.with_role(:contractor, :any)
    users.each do |user|
      NotificationMailer.contractor_notification(user).deliver_later
    end
  end

  task :workflow_inform_to_deadline_reminders => :environment do
    workflows = Workflow.where(completed: nil).where('deadline BETWEEN ? AND ?', Date.current.beginning_of_day, Date.current.end_of_day).all
    workflows.each do |workflow|
      NotificationMailer.inform_to_notification(workflow, 'deadline').deliver_later
    end
  end
end