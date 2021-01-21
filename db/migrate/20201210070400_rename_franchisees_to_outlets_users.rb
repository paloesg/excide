class RenameFranchiseesToOutletsUsers < ActiveRecord::Migration[6.0]
  def up
    rename_table :franchisees, :outlets_users
  end

  def down
    rename_table :outlets_users, :franchisees
  end
end
