class AddXeroNameToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :xero_organisation_name, :string
  end
end
