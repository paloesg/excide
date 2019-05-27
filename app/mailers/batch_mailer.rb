class BatchMailer < ApplicationMailer
	default from: 'noreply@excide.co'

	def daily_batch_email_summary(batches)
		batches.each
		@consultant = batch.company.consultant
		@url = @consultant.email
    mail(to: @url, subject: '[Batch Daily Progress] - ' + batch.id + ' - ' + Date.current.to_s)
  end
end
