class ChangeStorageUsedToBigInt < ActiveRecord::Migration[6.1]
  def up
    change_column :companies, :storage_limit, :bigint
    change_column :companies, :storage_used, :bigint
  end

  def down
    change_column :companies, :storage_limit, :int
    change_column :companies, :storage_used, :int
  end
end
