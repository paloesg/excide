class DowngradeSubscriptionService
  def initialize(company)
    @company = company
  end

  def run
    downgrade_company
    update_company_when_downgraded
  end

  private
  def downgrade_company
    @company.downgrade
  end

  def update_company_when_downgraded
    # Disconnect from xero when downgraded
    @company.update(expires_at: nil, access_key: nil, access_secret: nil, session_handle: nil, xero_organisation_name: nil)
    @company.stripe_subscription_plan_data['cancel'] = false
    @company.save
  end
end
