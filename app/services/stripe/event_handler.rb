# Stripe module
module Stripe
 # stripe main class EventHandler
  class EventHandler
    def call(event)
      method = 'handle_' + event.type.tr('.', '_')
      send method, event
    rescue JSON::ParserError => e
      render json: { status: 400, error: 'Invalid payload' }
      Raven.capture_exception(e)
    rescue Stripe::SignatureVerificationError => e
      render json: { status: 400, error: 'Invalid signature' }
      Raven.capture_exception(e)
    end

    def handle_checkout_session_completed(event)
      # your code goes here
      console.log("Success!")
    end
  end
end

# method = 'handle_' + event.type.tr('.', '_')

# event.type
# This will give the name of the event. In our case, it will give ‘charge.dispute.created’ and replace the ‘.’ with ‘_’ so it will become ‘charge_dispute_created’ and concat it with ‘handle_’.
# so it becomes ‘handle_charge_dispute_created’ as a method.

# send method, event

# This will call the method based on the method variable value. In our case, it will call ‘handle_charge_dispute_created’
# Same way it will handle the other events based on your events you need to define the method in service put your code in it!