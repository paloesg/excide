class Symphony::CheckoutController < ApplicationController
  layout "dashboard/application"
  layout 'metronic/application'
  def create
    @company = Company.find(params[:company_id])
    @session = Stripe::Checkout::Session.create(
      customer_email: current_user.email,
      payment_method_types: ['card'],
      subscription_data: {
        items: [{
          plan: 'plan_GMuEzp27rnQXc5',
        }],
      },
      success_url: symphony_checkout_success_url,
      cancel_url: symphony_checkout_cancel_url,
    )
    respond_to do |format|
      format.js
    end
  end

  def success

  end

  def cancel

  end
end
