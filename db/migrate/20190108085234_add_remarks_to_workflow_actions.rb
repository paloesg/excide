class AddRemarksToWorkflowActions < ActiveRecord::Migration[5.2]
  def change
    add_column :workflow_actions, :remarks, :string
  end
end
