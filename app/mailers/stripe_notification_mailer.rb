class StripeNotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'
  
  # Removed upcoming payment email notification, since it is not being used

  def cancel_subscription_notification(user, period_end)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: ENV['SENDGRID_CANCEL_SUBSCRIPTION_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
        period_end: period_end
      }
    )
  end

  def payment_successful(user, start_date, end_date, invoice_pdf)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: ENV['SENDGRID_PAYMENT_SUCCESSFUL_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
        start_date: start_date,
        end_date: end_date,
        invoice_pdf: invoice_pdf
      }
    )
  end

  def charge_failed(user)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: ENV['SENDGRID_CHARGE_FAILED_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
      }
    )
  end

  def free_trial_ending_notification(user, company)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: ENV['SENDGRID_FREE_TRIAL_ENDING_EMAIL_TEMPLATE'], dynamic_template_data: {
        firstName: user.first_name,
        company_name: company.name
      }
    )
  end
end
