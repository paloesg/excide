# Preview all emails at http://localhost:3000/rails/mailers/stripe_notification_mailer
#you can either log in to User.last account or change the User.last to User.find(your id)
class StripeNotificationMailerPreview < ActionMailer::Preview
  def upcoming_payment_notification
    StripeNotificationMailer.upcoming_payment_notification(User.last)
  end

  def payment_successful
    StripeNotificationMailer.payment_successful(User.last, 1000000000, 1100000000, Document.last.file_url)
  end
end