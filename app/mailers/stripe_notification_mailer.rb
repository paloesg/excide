class StripeNotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def upcoming_payment_notification(user)
    @user = user
    mail(to: @user.email, subject: '[Upcoming billing for Symphony PRO]')
  end

  def recurring_payment_successful(user)
  	@user = user
  	mail(to: @user.email, subject: '[Your subscription has been renewed!]')
  end
end