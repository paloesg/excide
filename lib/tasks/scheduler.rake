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

  task :update_symphony_trial_status => :environment do
    Company.all.each do |company|
      # Check for free trial end date
      if company.trial_end_date.present? and company.trial_end_date < DateTime.current and company.free_trial?
        company.users.each do |user|
          # Email users that their free trial ended
          StripeNotificationMailer.free_trial_ending_notification(User.find(170), company).deliver_later
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

  task :renew_outlet_notice => :environment do
    Franchisee.all.each do |f|
      # get franchisor from franchisee's company & then send email notification for renewal notice, eg if expiry date is 14 dec and renewal notice is 2 days, it should send out an email on 12 dec
      f.company.users.with_role(:franchisor, f.company).each do |user|
        NotificationMailer.motif_renewal_notice_outlet(f, user).deliver_now
      end
    end
  end
end
