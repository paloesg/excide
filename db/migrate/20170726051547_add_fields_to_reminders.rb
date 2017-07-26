class AddFieldsToReminders < ActiveRecord::Migration
  def change
    add_reference :reminders, :task, index: true, foreign_key: true
    add_reference :reminders, :action, index: true, foreign_key: true
  end
end
