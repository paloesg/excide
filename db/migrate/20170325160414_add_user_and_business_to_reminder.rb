class AddUserAndBusinessToReminder < ActiveRecord::Migration
  def change
    add_reference :reminders, :user, index: true, foreign_key: true
    add_reference :reminders, :business, index: true, foreign_key: true
  end
end
