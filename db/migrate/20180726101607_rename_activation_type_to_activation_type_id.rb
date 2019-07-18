class RenameActivationTypeToActivationTypeId < ActiveRecord::Migration[5.2]
  def change
    rename_column :activations, :activation_type, :activation_type_id
  end
end
