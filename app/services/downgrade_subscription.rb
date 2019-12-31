class DowngradeSubscription
  def initialize(company)
    @company = company
  end

  def run
    Stripe::Subscription.delete(@company.stripe_subscription_plan_data["id"])
    # append stripe invoice data to past invoice when subscription is cancelled
    @company.past_invoice << @company.stripe_invoice_data
    @company.downgrade
    @company.save
  end
end