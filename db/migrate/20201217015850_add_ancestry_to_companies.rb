class AddAncestryToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :ancestry, :string
    add_index :companies, :ancestry
  end
end
