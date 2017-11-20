class CreateDocumentTemplates < ActiveRecord::Migration
  def change
    create_table :document_templates do |t|
      t.string :title
      t.text :description
      t.string :file_url
      t.references :template, index: true, foreign_key: true
      t.references :task, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
