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
          plan: ENV['STRIPE_PLAN'],
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
      flash[:notice] = "Your account has been successfully upgraded to PRO."
      redirect_to edit_company_path
    else
      flash[:danger] = "Upgrading to PRO account has failed. Please contact the admin for more information."
      redirect_to symphony_root_path
    end
  end

  def cancel
    authorize :checkout, :cancel?
    current_user.company.stripe_subscription_plan_data['cancel'] = true
    # Cancel stripe subscription ONLY at the end of biling period
    Stripe::Subscription.update(
      current_user.company.stripe_subscription_plan_data['subscription']['id'],
      {
        cancel_at_period_end: true,
      }
    )
    current_user.company.save
    redirect_to symphony_root_path, alert: 'You have cancelled your subscription. You have still have the PRO features until the end of your subscription date. Re-subscribe to PRO for more Symphony advanced features.'
  end
end
