class AddTotalTimeToWorkflows < ActiveRecord::Migration[6.0]
  def change
    add_column :workflows, :total_time, :integer, default: 0
  end
end
