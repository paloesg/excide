class AddTaskTypeToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :task_type, :integer
  end
end
