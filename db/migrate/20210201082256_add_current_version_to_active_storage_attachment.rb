class AddCurrentVersionToActiveStorageAttachment < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_attachments, :current_version, :boolean, default: false
  end
end
