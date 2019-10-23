class BatchMailer < ApplicationMailer
  default from: 'noreply@excide.co'

  def daily_batch_email_summary(company)
    @consultant = company.consultant
    @batches = company.batches
    @url = company.consultant.email
    mail(to: @url, subject: "[Batch Upload Report] - " + company.name + " - " + Date.current.to_s)
  end

  def weekly_batch_email_summary
    @batches = Batch.includes(:company).where("updated_at >= ?", 1.week.ago.utc).group_by(&:company_id)
    mail(to: "chris@excide.co", subject: "Weekly Batch Report")
  end

end
