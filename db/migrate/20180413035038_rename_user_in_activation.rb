class RenameUserInActivation < ActiveRecord::Migration[5.2]
  def change
    rename_column :activations, :user_id, :event_owner_id
  end
end
