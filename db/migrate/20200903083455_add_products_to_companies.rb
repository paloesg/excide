class AddProductsToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :products, :json
  end
end
