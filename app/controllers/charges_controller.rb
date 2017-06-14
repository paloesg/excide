class ChargesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

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

    @user.make_payment
    @user.save

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end

  private

  def set_user
    @user = current_user
  end
end
