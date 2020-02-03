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
      # Find the current_user using the data returned by stripe webhook
      @current_user = User.find_by(stripe_customer_id: event.data.object.customer)
      # Store the event data into database of company
      puts "stripe Subscription: #{event.data.object.subscription}"
      # If stripe data is empty, initialize it
      if @current_user.company.stripe_subscription_plan_data.empty?
        @current_user.company.stripe_subscription_plan_data = {
          subscription: Stripe::Subscription.retrieve(event.data.object.subscription),
          invoices: [ Stripe::Invoice.retrieve(Stripe::Subscription.retrieve(event.data.object.subscription)["latest_invoice"]) ],
          cancel: false,
        }
      #else, append the invoice data to the invoices key
      else
        @current_user.company.stripe_subscription_plan_data['subscription'] = Stripe::Subscription.retrieve(event.data.object.subscription)
        @current_user.company.stripe_subscription_plan_data['invoices'] << Stripe::Invoice.retrieve(Stripe::Subscription.retrieve(event.data.object.subscription)["latest_invoice"])
      end
      @current_user.company.upgrade
      @current_user.company.save
    end

    # def handle_invoice_upcoming(event)
    #   @current_user = User.find_by(stripe_customer_id: event.data.object.customer)
    #   # Notify user when payment is upcoming for the next month
    #   StripeNotificationMailer.upcoming_payment_notification(@current_user).deliver_later
    # end

    def handle_invoice_payment_succeeded(event)
      @current_user = User.find_by(stripe_customer_id: event.data.object.customer)
      puts "CURRENT USER : #{event.data.object.subscription}"
      subscription = Stripe::Subscription.retrieve(event.data.object.subscription)
      period_start = subscription["current_period_start"]
      period_end = subscription["current_period_end"]
      invoice_pdf = event.data.object["invoice_pdf"]
      StripeNotificationMailer.payment_successful(@current_user, period_start, period_end, invoice_pdf).deliver
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