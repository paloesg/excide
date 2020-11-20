class AddLinksToWorkflowAction < ActiveRecord::Migration[6.0]
  def change
    add_column :workflow_actions, :links, :json, default: {}
  end
end
