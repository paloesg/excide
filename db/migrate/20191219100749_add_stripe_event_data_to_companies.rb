class AddStripeEventDataToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :stripe_event_data, :json, default: {}
  end
end
