class RenameColumnEventOwner < ActiveRecord::Migration[5.2]
  def change
    rename_column :activations, :event_owner_id, :staffer_id
  end
end
