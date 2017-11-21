class AddWorkflowToDocuments < ActiveRecord::Migration
  def change
    add_reference :documents, :workflow, index: true, foreign_key: true
  end
end
