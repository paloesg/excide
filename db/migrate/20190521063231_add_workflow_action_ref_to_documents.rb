class AddWorkflowActionRefToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :workflow_action, foreign_key: true
  end
end
