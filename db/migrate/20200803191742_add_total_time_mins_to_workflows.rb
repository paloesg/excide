class AddTotalTimeMinsToWorkflows < ActiveRecord::Migration[6.0]
  def change
    add_column :workflows, :total_time_mins, :integer, default: 0
  end
end
