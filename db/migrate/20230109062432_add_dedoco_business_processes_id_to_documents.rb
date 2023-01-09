class AddDedocoBusinessProcessesIdToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :dedoco_business_processes_id, :string
  end
end
