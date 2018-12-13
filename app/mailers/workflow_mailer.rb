class WorkflowMailer < ApplicationMailer
  require 'open-uri'
  default from: 'notifications@example.com'

  def welcome_email(workflow, workflow_docs)
    @workflow = workflow

    uri = URI("http:"+ workflow_docs.file_url.to_s)
    attachments[workflow_docs.filename] = open(uri).read

    # @url  = 'bills.cl7rd.26i7pbxgzjw8sgdk@xerofiles.com'
    @url = 'Jonathanknight1211@gmail.com'
    mail(to: @url, subject: 'Xero bill invoice')
  end
end
