class AddXeroEmailToCompanies < ActiveRecord::Migration[5.2]
  def change
     add_column :companies, :xero_email, :string
  end
end
