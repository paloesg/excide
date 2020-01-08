class StripeNotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def upcoming_payment_notification(user)
    @user = user
    mail(to: @user.email, subject: '[Upcoming billing for Symphony PRO]')
  end

  def payment_successful(user, start_date, end_date, invoice_pdf)
    @user = user
    @start_date = start_date
    @end_date = end_date
    @invoice_pdf = invoice_pdf
    mail(to: @user.email, subject: '[Payment has been made successfully]')
  end
end