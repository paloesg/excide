class RenameColumnActivationToEvent < ActiveRecord::Migration[5.2]
  def change
    rename_column :allocations, :activation_id, :event_id
  end
end
