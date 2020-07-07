class AddDeadlineAttributesToTasks < ActiveRecord::Migration[6.0]
  def change
  	rename_column :tasks, :days_to_complete, :deadline_day
  	add_column :tasks, :deadline_type, :integer
  end
end
