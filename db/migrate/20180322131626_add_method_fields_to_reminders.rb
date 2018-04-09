class AddMethodFieldsToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :email, :boolean
    add_column :reminders, :sms, :boolean
    add_column :reminders, :slack, :boolean
  end
end
