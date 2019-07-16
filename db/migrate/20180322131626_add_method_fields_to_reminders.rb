class AddMethodFieldsToReminders < ActiveRecord::Migration[5.2]
  def change
    add_column :reminders, :email, :boolean
    add_column :reminders, :sms, :boolean
    add_column :reminders, :slack, :boolean
  end
end
