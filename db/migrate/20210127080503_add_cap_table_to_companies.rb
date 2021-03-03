class AddCapTableToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :capitalization_table_url, :string
  end
end
