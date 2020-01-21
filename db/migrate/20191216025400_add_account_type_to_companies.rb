class AddAccountTypeToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :account_type, :integer
  end
end
