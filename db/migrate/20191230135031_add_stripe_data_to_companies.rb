class AddStripeDataToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :trial_end_date, :datetime
    add_column :companies, :stripe_invoice_data, :json, default: []
    add_column :companies, :stripe_subscription_plan_data, :json, default: []
  end
end
