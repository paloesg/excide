class ChangeStorageLimitFromFranchiseesToCompanies < ActiveRecord::Migration[6.0]
  def change
    remove_column :franchisees, :storage_space, :integer
    # Measured in bytesize
    add_column :companies, :storage_limit, :integer
    add_column :companies, :storage_used, :integer
  end
end
