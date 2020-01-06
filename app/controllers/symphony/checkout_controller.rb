class Symphony::CheckoutController < ApplicationController
  layout "dashboard/application"
  layout 'metronic/application'
  after_action :verify_authorized
  def create
    authorize :checkout, :create?
    # Create a stripe account for existing user (without having to register again)
    if current_user.stripe_customer_id.nil?
      current_user.stripe_customer_id = Stripe::Customer.create({email: current_user.email}).id
      current_user.save
    end
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
    authorize :checkout, :success?
    if params[:session_id]
      flash[:notice] = "Thanks for your Subscribing to Symphony PRO."
      redirect_to edit_company_path
    else
      flash[:error] = "Session expired error"
      redirect_to symphony_root_path
    end
  end

  def cancel
    authorize :checkout, :cancel?
    DowngradeSubscription.new(current_user.company).run
    redirect_to symphony_root_path, alert: 'You have cancelled your subscription. Re-subscribe to it for more Symphony advanced features.'
  end
end
