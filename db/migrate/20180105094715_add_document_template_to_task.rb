class AddDocumentTemplateToTask < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :document_template, index: true, foreign_key: true
  end
end
