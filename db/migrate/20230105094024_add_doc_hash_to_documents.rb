class AddDocHashToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :doc_hash, :string
  end
end
