class AddConnectXeroToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :connect_xero, :boolean, default: true
  end
end
