class AddAttachedToActiveStorageBlob < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_blobs, :attached, :boolean
  end
end
