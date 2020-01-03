class DowngradeSubscription
  def initialize(company)
    @company = company
  end

  def run
    append_past_invoices
    delete_stripe_subscription
  end

  private
  def delete_stripe_subscription
    Stripe::Subscription.delete(@company.stripe_subscription_plan_data["subscription"]["id"])
  end

  def append_past_invoices
    # append stripe invoice data to past invoice when subscription is cancelled
    @company.stripe_subscription_plan_data["past_invoices"] << @company.stripe_subscription_plan_data["current_invoice"]
    @company.stripe_subscription_plan_data["current_invoice"] = nil
    @company.downgrade
    @company.save
  end
end