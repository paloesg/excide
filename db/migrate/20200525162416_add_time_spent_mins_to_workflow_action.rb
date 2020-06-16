class AddTimeSpentMinsToWorkflowAction < ActiveRecord::Migration[6.0]
  def change
    add_column :workflow_actions, :time_spent_mins, :integer
  end
end
