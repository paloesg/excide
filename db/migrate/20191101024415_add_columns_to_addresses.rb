class AddColumnsToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :city, :string
    add_column :addresses, :country, :string
    add_column :addresses, :state, :string
  end
end
