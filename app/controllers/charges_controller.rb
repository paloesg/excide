class ChargesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    # Amount in cents
    @amount = 2500

    customer = Stripe::Customer.create(
      :email => current_user.email,
      :description => [current_user.first_name, current_user.last_name].join(' ').squeeze(' '),
      :source  => params[:stripeToken]
    )

    subscription = Stripe::Subscription.create(
      :customer => customer.id,
      :plan => "compliance-toolkit",
    )

    current_user.make_payment
    current_user.save

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end
end
