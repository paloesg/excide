class AddWorkflowTypeToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :workflow_type, :string
  end
end