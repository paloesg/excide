class DowngradeSubscription
  def initialize(company)
    @company = company
  end

  def run
    Stripe::Subscription.delete(@company.stripe_subscription_plan_data["id"])
    @company.downgrade
    @company.save
  end
end