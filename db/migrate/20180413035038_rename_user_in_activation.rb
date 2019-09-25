class RenameUserInActivation < ActiveRecord::Migration[5.2]
  def change
    rename_column :activations, :user_id, :staffer_id
  end
end
