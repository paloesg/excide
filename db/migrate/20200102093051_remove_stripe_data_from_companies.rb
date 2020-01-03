class RemoveStripeDataFromCompanies < ActiveRecord::Migration[6.0]
  def change
    remove_column :companies, :stripe_invoice_data, :json
    remove_column :companies, :past_invoice, :json
  end
end
