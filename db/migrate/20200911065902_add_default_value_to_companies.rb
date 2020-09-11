class AddDefaultValueToCompanies < ActiveRecord::Migration[6.0]
  def change
    change_column :companies, :products, :json, :default => []
  end
end
