class DowngradeSubscription
  def initialize(company)
    @company = company
  end

  def run
    delete_stripe_subscription
    append_past_invoices
  end

  private
  def delete_stripe_subscription
    Stripe::Subscription.delete(@company.stripe_subscription_plan_data["id"])
  end

  def append_past_invoices
    # append stripe invoice data to past invoice when subscription is cancelled
    @company.past_invoice << @company.stripe_invoice_data
    @company.downgrade
    @company.save
  end
end