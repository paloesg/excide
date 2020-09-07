class AddCurrentActionToWorkflowActions < ActiveRecord::Migration[6.0]
  def change
    add_column :workflow_actions, :current_action, :boolean, :default => false
  end
end
