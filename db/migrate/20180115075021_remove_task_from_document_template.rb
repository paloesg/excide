class RemoveTaskFromDocumentTemplate < ActiveRecord::Migration[5.2]
  def change
    remove_reference :document_templates, :task, index: true, foreign_key: true
  end
end
