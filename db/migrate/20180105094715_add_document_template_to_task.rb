class AddDocumentTemplateToTask < ActiveRecord::Migration
  def change
    add_reference :tasks, :document_template, index: true, foreign_key: true
  end
end
