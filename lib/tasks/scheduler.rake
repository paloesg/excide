namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on"

  task :send_reminders => :environment do
    reminders = Reminder.today
    reminders.each do |reminder|
      reminder.send_reminder
    end
  end
end