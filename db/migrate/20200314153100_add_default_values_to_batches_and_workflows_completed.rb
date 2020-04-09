class AddDefaultValuesToBatchesAndWorkflowsCompleted < ActiveRecord::Migration[6.0]
  def change
    change_column_default :batches, :completed, false
    change_column_default :workflows, :completed, false
  end
end
