class RenameActivationTypeToActivationTypeId < ActiveRecord::Migration
  def change
    rename_column :activations, :activation_type, :activation_type_id
  end
end
