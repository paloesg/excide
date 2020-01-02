class GenerateStripeInvoice
  def initialize(company)
    @company = company
  end

  def run
    retrive_invoice
  end

  private
  def retrive_invoice
  	@company.stripe_invoice_data = Stripe::Invoice.retrieve(@company.stripe_subscription_plan_data["latest_invoice"])
  	@company.save
  end
end