class AddDocumentTemplateToDocuments < ActiveRecord::Migration
  def change
    add_reference :documents, :document_template, index: true, foreign_key: true
  end
end
