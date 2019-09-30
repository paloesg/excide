class RenameActivationToEvent < ActiveRecord::Migration[5.2]
  def change
    rename_table :activation_types, :event_types
    rename_table :activations, :events
    rename_column :events, :activation_type_id, :event_type_id
  end
end
