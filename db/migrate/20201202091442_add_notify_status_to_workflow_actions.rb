class AddNotifyStatusToWorkflowActions < ActiveRecord::Migration[6.0]
  def change
    add_column :workflow_actions, :notify_status, :boolean, default: false
  end
end
