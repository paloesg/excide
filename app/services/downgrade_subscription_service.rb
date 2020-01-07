class DowngradeSubscriptionService
  def initialize(company)
    @company = company
  end

  def run
    delete_stripe_subscription
    downgrade_company
    update_company_when_downgraded
  end

  private
  def delete_stripe_subscription
    Stripe::Subscription.delete(@company.stripe_subscription_plan_data["subscription"]["id"])
  end

  def downgrade_company
    @company.downgrade
  end

  def update_company_when_downgraded
    # Disconnect from xero when downgraded
    @company.update_attributes(expires_at: nil, access_key: nil, access_secret: nil, session_handle: nil, xero_organisation_name: nil)
    @company.save
  end
end