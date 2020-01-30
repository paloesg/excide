class AddProgressToBatch < ActiveRecord::Migration[6.0]
  def change
    add_column :batches, :workflow_progress, :integer
    add_column :batches, :task_progress, :integer
  end
end
