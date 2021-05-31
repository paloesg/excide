class AddStorageToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :storage_used, :bigint, default: 0
    add_column :companies, :storage_limit, :bigint, default: 16106127360
  end
end
