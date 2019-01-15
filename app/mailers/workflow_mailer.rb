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

  def email_summary(workflow_action, user)
    @workflow_action = workflow_action
    @url = user.email
    mail(to: @url, subject: 'Task completed')
  end
end