class AddStripeSubscriptionPlanDataAndTrialEndDateToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :stripe_subscription_plan_data, :json
    add_column :companies, :trial_end_date, :datetime
  end
end
