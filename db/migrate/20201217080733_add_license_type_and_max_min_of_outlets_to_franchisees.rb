class AddLicenseTypeAndMaxMinOfOutletsToFranchisees < ActiveRecord::Migration[6.0]
  def change
    add_column :franchisees, :license_type, :integer
    add_column :franchisees, :max_outlet, :integer
    add_column :franchisees, :min_outlet, :integer
    add_column :franchisees, :storage_space, :integer
  end
end
