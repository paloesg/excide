class ChangeDocumentTemplateIdToUuid < ActiveRecord::Migration[6.0]
  def change
    # remove the old foreign_key
    remove_foreign_key :tasks, :document_templates
    remove_foreign_key :documents, :document_templates
    
    enable_extension 'uuid-ossp'
    add_column :document_templates, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    # Add temporary uuid column for associated model
    add_column :documents, :document_template_uuid, :uuid
    add_column :tasks, :document_template_uuid, :uuid

    # Move existing document_template_id to the uuid column
    DocumentTemplate.find_each do |document_template|
      Document.where(document_template_id: document_template.id).find_each do |document|
        document.document_template_uuid = document_template.uuid
        document.save!
      end

      Task.where(document_template_id: document_template.id).find_each do |task|
        task.document_template_uuid = document_template.uuid
        task.save!
      end
    end

    remove_reference :documents, :document_template
    remove_reference :tasks, :document_template

    change_table :document_templates do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute "ALTER TABLE document_templates ADD PRIMARY KEY (id);"
    # Rename temporary uuid column back to id
    rename_column :documents, :document_template_uuid, :document_template_id
    rename_column :tasks, :document_template_uuid, :document_template_id

    add_foreign_key :documents, :document_templates
    add_foreign_key :tasks, :document_templates
  end

end
