class RemoveTaskFromDocumentTemplate < ActiveRecord::Migration
  def change
    remove_reference :document_templates, :task, index: true, foreign_key: true
  end
end
