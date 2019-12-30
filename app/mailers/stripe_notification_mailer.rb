class StripeNotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def upcoming_payment_notification(user)
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.full_name
    mail(to: address.format, subject: '[Upcoming billing for Symphony PRO]')
  end
end