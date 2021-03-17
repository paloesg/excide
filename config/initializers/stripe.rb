Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_SECRET_KEY'],
  :signing_secret  => ENV['STRIPE_SIGNING_SECRET']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
StripeEvent.signing_secret = Rails.configuration.stripe[:signing_secret]

StripeEvent.configure do |events|
  events.subscribe 'checkout.session.completed', Stripe::SymphonyEventHandler.new
  events.subscribe 'customer.subscription.created', Stripe::SymphonyEventHandler.new
  events.subscribe 'customer.subscription.updated', Stripe::SymphonyEventHandler.new
  events.subscribe 'customer.subscription.deleted', Stripe::SymphonyEventHandler.new
  events.subscribe 'invoice.upcoming', Stripe::SymphonyEventHandler.new
  events.subscribe 'invoice.payment_succeeded', Stripe::SymphonyEventHandler.new
  events.subscribe 'charge.failed', Stripe::SymphonyEventHandler.new
end
