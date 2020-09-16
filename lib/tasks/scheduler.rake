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

  # Rake task for the the daily summary email
  task :daily_summary => :environment do
    time = Benchmark.realtime {
      User.all.each do |user|
        SendDailySummary.run(user)
      end
    }

    Snitcher.snitch(ENV['SNITCH_TOKEN'], message: "Finished in #{time.round(2)} seconds.")
  end

  task :generate_next_workflow => :environment do
    Template.today.each do |t|
      # Check if next_workflow_date is after end date of project
      if t.next_workflow_date < t.end_date
        # Since user is the same for all workflows, we can do workflows[0].user
        workflow = Workflow.create(user: t.workflows[0].user, company: t.company, template: t)
        t.set_next_workflow_date(workflow)
      end
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

  task :update_symphony_trial_status => :environment do
    Company.all.each do |company|
      # Check for free trial end date
      if company.trial_end_date.present? and company.trial_end_date < DateTime.current and company.free_trial?
        # email users if free trial ended
        company.users.each do |user|
          NotificationMailer.free_trial_ending_notification(user).deliver_later
        end
        company.trial_ends  #only from free trial to basic
        company.update_attributes(expires_at: nil, access_key: nil, access_secret: nil, session_handle: nil, xero_organisation_name: nil)
        company.save
      end
    end
  end

  task :recurring_workflows => :environment do
    #To check that workflow is recurring today (current date)
    @recurring_workflows = RecurringWorkflow.today
    @recurring_workflows.each do |recurring_workflow|
      GenerateRecurringWorkflow.new(recurring_workflow).run
    end
  end
end
