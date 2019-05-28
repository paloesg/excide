class BatchMailer < ApplicationMailer
  default from: 'noreply@excide.co'

  def daily_batch_email_summary(company)
    @consultant = company.consultant
    @batches = company.batches
    @url = company.consultant.email
    mail(to: @url, subject: "[Batch Daily Progress] - " + company.name + "'s batches - " + Date.current.to_s)
  end
end
