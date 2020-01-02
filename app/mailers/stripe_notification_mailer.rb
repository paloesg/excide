class StripeNotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def upcoming_payment_notification(user)
    @user = user
    mail(to: @user.email, subject: '[Upcoming billing for Symphony PRO]')
  end
end