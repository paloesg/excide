class RenameBusinessesToCompanies < ActiveRecord::Migration
  def change
    rename_table :businesses, :companies
  end
end
