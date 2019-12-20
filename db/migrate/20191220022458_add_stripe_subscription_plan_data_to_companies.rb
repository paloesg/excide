class AddStripeSubscriptionPlanDataToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :stripe_subscription_plan_data, :json, default: {}
  end
end
