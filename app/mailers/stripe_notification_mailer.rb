class StripeNotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'
  
  # Removed upcoming payment email notification, since it is not being used

  def cancel_subscription_notification(user, period_end)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: "d-b943fd3d9f7e4770951f4a1cb1d9e8c2", dynamic_template_data: {
        firstName: user.first_name,
        period_end: period_end
      }
    )
  end

  def payment_successful(user, start_date, end_date, invoice_pdf)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: "d-58d4d5a62dbc4cfe9eab4ddedfd2e24f", dynamic_template_data: {
        firstName: user.first_name,
        start_date: start_date,
        end_date: end_date,
        invoice_pdf: invoice_pdf
      }
    )
  end

  def charge_failed(user)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: "d-50cf7d8ce4654e30a8d22e88a275f6e7", dynamic_template_data: {
        firstName: user.first_name,
      }
    )
  end

  def free_trial_ending_notification(user, company)
    mail(to: user.email, from: 'Paloe Symphony <admin@excide.co>', subject: '[Symphony]Subscription Update', body: 'Some body',  template_id: "d-a8b2a552f6e74c5d957cebe120a35800", dynamic_template_data: {
        firstName: user.first_name,
        company_name: company.name
      }
    )
  end
end
