class ChangeForeignKeyForActiveOutlet < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :outlet_id, :active_outlet_id
  end
end
