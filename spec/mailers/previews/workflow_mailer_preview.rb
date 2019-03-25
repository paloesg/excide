# Preview all emails at http://localhost:3000/rails/mailers/workflow_mailer
class WorkflowMailerPreview < ActionMailer::Preview
  def welcome_email(workflow)
    @workflow = workflow

    @workflow.documents.each do |wf|
      attachments[wf.filename] = File.read(wf.file_url)
    end

    # @url  = 'bills.cl7rd.26i7pbxgzjw8sgdk@xerofiles.com'
    @url = 'Jonathanknight1211@gmail.com'
    mail(to: @url, subject: 'Xero bill invoice')
  end

end