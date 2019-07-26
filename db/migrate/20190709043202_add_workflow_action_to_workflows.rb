class AddWorkflowActionToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_reference :workflows, :workflow_action, foreign_key: true
  end
end
