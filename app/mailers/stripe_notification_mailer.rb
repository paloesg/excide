class StripeNotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def upcoming_payment_notification(user)
    @user = user
    mail(to: @user.email, subject: '[Upcoming billing for Symphony PRO]')
  end

  def cancel_subscription_notification(user, period_end)
    @user = user
    @period_end = period_end
    mail(to: @user.email, subject: '[You have cancelled Symphony PRO]')
  end

  def payment_successful(user, start_date, end_date, invoice_pdf)
    @user = user
    @start_date = start_date
    @end_date = end_date
    @invoice_pdf = invoice_pdf
    mail(to: @user.email, subject: '[Payment has been made successfully]')
  end

  def charge_failed(user)
    @user = user
    mail(to: @user.email, subject: '[Payment to subscribe Symphony PRO has failed]')
  end
end
