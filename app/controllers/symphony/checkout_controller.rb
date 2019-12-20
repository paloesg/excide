class Symphony::CheckoutController < ApplicationController
  layout "dashboard/application"
  layout 'metronic/application'
  def create
    @company = Company.find(params[:company_id])

    @session = Stripe::Checkout::Session.create(
      customer: current_user.stripe_customer_id,
      payment_method_types: ['card'],
      subscription_data: {
        items: [{
          plan: 'plan_GMuEzp27rnQXc5',
        }],
      },
      success_url: symphony_checkout_success_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: symphony_checkout_cancel_url,
    )
    respond_to do |format|
      format.js
    end
  end

  def success
    if params[:session_id]
      flash[:notice] = "Thanks for your Subscribing to Symphony PRO."
      redirect_to edit_company_path
    else
      flash[:error] = "Session expired error"
      redirect_to symphony_root_path
    end
  end

  def cancel

  end
end
