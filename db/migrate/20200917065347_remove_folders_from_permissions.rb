class RemoveFoldersFromPermissions < ActiveRecord::Migration[6.0]
  def change
    remove_reference :permissions, :folder, foreign_key: true
  end
end
