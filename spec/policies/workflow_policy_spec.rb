require 'rails_helper'

RSpec.describe WorkflowPolicy do
  subject { WorkflowPolicy.new(user, workflow) }

  company = FactoryBot.create(:company)
  user_of_workflow = FactoryBot.create(:user)
  user_of_company = FactoryBot.create(:user, company: company)
  admin_of_company = FactoryBot.create(:company_admin, company: company)

  user_of_workflow.add_role :consultant, company
  user_of_company.add_role :any, company
  admin_of_company.add_role :any, company

  let(:workflow) { FactoryBot.create(:workflow, company: company, user: user_of_workflow) }

  context "for a user" do
    let(:user) { FactoryBot.create(:user) }
    it { should permit(:index) }
    it { should_not permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should_not permit(:assign) }
    it { should_not permit(:archive) }
    it { should_not permit(:reset) }
    it { should_not permit(:activities) }
    it { should_not permit(:data_entry) }
    it { should_not permit(:xero_create_invoice_payable) }
    it { should_not permit(:destroy) }
  end

  # for a user of workflow and match with the task's roles
  context "for a user of workflow" do
    let(:user) { user_of_workflow }
    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should permit(:assign) }
    it { should permit(:archive) }
    it { should_not permit(:reset) }
    it { should permit(:activities) }
    it { should permit(:data_entry) }
    it { should permit(:xero_create_invoice_payable) }
    it { should_not permit(:destroy) }
  end

  context "for a user of company" do
    let(:user) { user_of_company }
    it { should permit(:index) }
    it { should_not permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should_not permit(:assign) }
    it { should_not permit(:archive) }
    it { should_not permit(:reset) }
    it { should_not permit(:activities) }
    it { should_not permit(:data_entry) }
    it { should_not permit(:xero_create_invoice_payable) }
    it { should_not permit(:destroy) }
  end

  context "for a admin of company" do
    let(:user) { admin_of_company }
    it { should permit(:index) }
    it { should_not permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should_not permit(:assign) }
    it { should_not permit(:archive) }
    it { should permit(:reset) }
    it { should_not permit(:activities) }
    it { should_not permit(:data_entry) }
    it { should_not permit(:xero_create_invoice_payable) }
    it { should permit(:destroy) }
  end
end
