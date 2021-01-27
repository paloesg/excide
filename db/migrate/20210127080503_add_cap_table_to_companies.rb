class AddCapTableToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :capitalization_table, :string
  end
end
