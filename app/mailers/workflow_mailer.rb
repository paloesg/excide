class WorkflowMailer < ApplicationMailer
  require 'open-uri'
  default from: 'noreply@excide.co'

  def send_invoice_email(workflow, workflow_document)
    @workflow = workflow
    uri = URI("http:"+ workflow_document.file_url.to_s)
    attachments[workflow_document.filename] = open(uri).read

    @url = @workflow.company.xero_email
    mail(to: @url, subject: 'Xero bill invoice')
  end

  # For scheduler: deadline_send_summary_email
  def email_summary(workflow, user, company)
    @workflow = workflow
    @user = user
    @company = company
    @url = user.email
    mail(to: @url, subject: '[Completed] ' + workflow.template.title + ' - ' + workflow.friendly_id + ' completed')
  end
end
