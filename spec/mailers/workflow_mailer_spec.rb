require "rails_helper"

RSpec.describe WorkflowMailer, type: :mailer do
  pending "add some examples to (or delete) #{__FILE__}"

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @workflow = Factory.create(:workflow)
    EbookConfirmationMailer.confirmation_email(@workflow).deliver
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  it 'should send an email' do
    ActionMailer::Base.deliveries.count.should == 1
  end

  it 'renders the receiver email' do
    ActionMailer::Base.deliveries.first.to.should == @workflow.workflowable.xero_email
  end

  it 'should set the subject to the correct subject' do
    ActionMailer::Base.deliveries.first.subject.should == 'Xero bill invoice'
  end



end
