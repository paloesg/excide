class AddFieldsToReminder < ActiveRecord::Migration
  def change
    add_column :reminders, :title, :string
    add_column :reminders, :content, :text
  end
end
