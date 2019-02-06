class ChangeAddToXeroTypeToBoolean < ActiveRecord::Migration[5.2]
  def change
    change_column :clients, :add_to_xero, "boolean USING CAST(add_to_xero AS boolean)"
  end
end