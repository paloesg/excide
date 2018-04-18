class RenameUserInActivation < ActiveRecord::Migration
  def change
    rename_column :activations, :user_id, :event_owner_id
  end
end
