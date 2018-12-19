class WorkflowMailer < ApplicationMailer
  require 'open-uri'
  default from: 'notifications@example.com'

  def send_invoice_email(workflow, workflow_document)
    @workflow = workflow

    uri = URI("http:"+ workflow_document.file_url.to_s)
    attachments[workflow_document.filename] = open(uri).read

    # @url  = 'bills.cl7rd.26i7pbxgzjw8sgdk@xerofiles.com'
    @url = ENV['XERO_ADDRESS_TO_SEND_EMAIL']
    mail(to: @url, subject: 'Xero bill invoice')
  end
end
