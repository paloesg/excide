class AddHasDocumentToActiveStorageBlobs < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_blobs, :has_document, :boolean
  end
end
