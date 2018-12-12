class WorkflowMailer < ApplicationMailer
  require 'open-uri'
  default from: 'notifications@example.com'

  def welcome_email(workflow)
    @workflow = workflow

    @workflow.documents.each do |wf|
      uri = URI("http:"+ wf.file_url.to_s)
      attachments[wf.filename] = open(uri).read
    end

    # @url  = 'bills.cl7rd.26i7pbxgzjw8sgdk@xerofiles.com'
    @url = 'Jonathanknight1211@gmail.com'
    mail(to: @url, subject: 'Xero bill invoice')
  end
end
