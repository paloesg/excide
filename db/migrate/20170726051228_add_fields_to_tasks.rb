class AddFieldsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :days_to_complete, :integer
    add_column :tasks, :set_reminder, :boolean
  end
end
