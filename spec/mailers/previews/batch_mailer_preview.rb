# Preview all emails at http://localhost:3000/rails/mailers/batch_mailer
class BatchMailerPreview < ActionMailer::Preview
  def daily_batch_email_summary
    #find a company with a consultant
    BatchMailer.daily_batch_email_summary(Company.find(11))
  end

  def weekly_batch_email_summary
    BatchMailer.weekly_batch_email_summary
  end

end
