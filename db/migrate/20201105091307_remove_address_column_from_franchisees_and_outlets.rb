class RemoveAddressColumnFromFranchiseesAndOutlets < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :franchisees, :address
    remove_column :outlets, :address
    rename_column :outlets, :telephone, :contact
    rename_column :franchisees, :telephone, :contact
  end

  def self.down
    add_column :franchisees, :address, :string
    add_column :outlets, :address, :string
    rename_column :outlets, :contact, :telephone
    rename_column :franchisees, :contact, :telephone
  end
end
