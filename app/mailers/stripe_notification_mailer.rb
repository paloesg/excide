class StripeNotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'
  # def upcoming_payment_notification(user)
  #   @user = user
  #   mail(to: @user.email, subject: '[Upcoming billing for Symphony PRO]')
  # end

  def cancel_subscription_notification(user, period_end)
    mail(to: 'jonathan.lau@paloe.com.sg', from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: "d-b943fd3d9f7e4770951f4a1cb1d9e8c2", dynamic_template_data: {
        firstName: user.first_name,
        period_end: period_end
      }
    )
  end

  def payment_successful(user, start_date, end_date, invoice_pdf)
    mail(to: 'jonathan.lau@paloe.com.sg', from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: "d-58d4d5a62dbc4cfe9eab4ddedfd2e24f", dynamic_template_data: {
        firstName: user.first_name,
        start_date: start_date,
        end_date: end_date,
        invoice_pdf: invoice_pdf
      }
    )
  end

  def charge_failed(user)
    mail(to: 'jonathan.lau@paloe.com.sg', from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: ENV['SENDGRID_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
      }
    )
  end

  def free_trial_ending_notification(user)
    mail(to: 'jonathan.lau@paloe.com.sg', from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: "d-a8b2a552f6e74c5d957cebe120a35800", dynamic_template_data: {
        firstName: user.first_name,
      }
    )
  end
end
