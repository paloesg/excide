class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.datetime :next_reminder
      t.boolean :repeat
      t.integer :freq_value
      t.integer :freq_unit
      t.datetime :past_reminders, array: true, default: []

      t.timestamps null: false
    end
  end
end
