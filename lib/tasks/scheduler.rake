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

  task :deadline_send_summary_email => :environment do
    @workflows = Workflow.where(deadline: (Date.current - 1.day).beginning_of_day)
    @workflows.each do |workflow|
      WorkflowMailer.email_summary(workflow, workflow.user, workflow.company).deliver_later unless workflow.batch.present?
    end
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

  task :associate_reminders => :environment do
    users = User.with_role(:associate, :any)
    users.each do |user|
      NotificationMailer.associate_notification(user).deliver_later
    end
  end

  task :daily_batch_email_summary => :environment do
    Company.all.each do |company|
      if company.batches.present? and company.consultant.present?
        BatchMailer.daily_batch_email_summary(company).deliver_later if company.consultant.settings[0]&.batch_email == 'true'
      end
    end
  end

  task :weekly_batch_email_summary => :environment do
    BatchMailer.weekly_batch_email_summary.deliver_later if Date.current.monday?
  end

  task :check_trial_ended => :environment do
    Company.all.each do |company|
      if company.trial_end_date.present? and company.trial_end_date < DateTime.current and company.free_trial?
        # email users if free trial ended
        company.users.each do |user|
          NotificationMailer.free_trial_ending_notification(user).deliver
        end
        company.trial_ends  #only from free trial to basic
        company.save
      end
    end
  end
end
