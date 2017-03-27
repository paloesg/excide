namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on"

  task :daily_reminders => :environment do
    time = Benchmark.realtime {
      reminders = Reminder.today
      reminders.each do |reminder|
        reminder.send_reminder
      end
    }

    Snitcher.snitch("64699878dc", message: "Finished in #{time.round(2)} seconds.")
  end
end