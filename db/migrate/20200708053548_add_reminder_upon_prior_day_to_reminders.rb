class AddReminderUponPriorDayToReminders < ActiveRecord::Migration[6.0]
  def change
    add_column :reminders, :prior_reminder, :datetime
  end
end
