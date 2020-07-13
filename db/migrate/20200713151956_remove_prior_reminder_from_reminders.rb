class RemovePriorReminderFromReminders < ActiveRecord::Migration[6.0]
  def change
    remove_column :reminders, :prior_reminder, :datetime
  end
end
