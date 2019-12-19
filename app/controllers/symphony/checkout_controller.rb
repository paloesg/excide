class Symphony::CheckoutController < ApplicationController
  layout "dashboard/application"
  layout 'metronic/application'
  def create
    @company = Company.find(params[:company_id])

    @session = Stripe::Checkout::Session.create(
      customer: current_user.stripe_customer_id,
      customer_email: current_user.email,
      payment_method_types: ['card'],
      subscription_data: {
        items: [{
          plan: 'plan_GMuEzp27rnQXc5',
        }],
      },
      success_url: symphony_checkout_success_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: symphony_checkout_cancel_url,
    )
    if @session.present?
      @company.account_type = 'pro' 
      @company.save
    end
    respond_to do |format|
      format.js
    end
  end

  def success
    if params[:session_id]
      flash[:notice] = "Thanks for your Subscribing to Symphony PRO."
    else
      flash[:error] = "Session expired error"
      redirect_to symphony_root_path
    end
  end

  def cancel

  end
end
