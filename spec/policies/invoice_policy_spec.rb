require 'rails_helper'

RSpec.describe InvoicePolicy do
  subject { InvoicePolicy.new(user, invoice) }
  company = FactoryBot.create(:company)
  user_of_invoice = FactoryBot.create(:user, company: company)
  admin_of_company = FactoryBot.create(:company_admin, company: company)
  let(:invoice) { FactoryBot.create(:invoice, company: company, user: user_of_invoice) }

  context "for a user" do
    let(:user) { FactoryBot.create(:user) }
    it { should_not permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should_not permit(:destroy) }
  end

  context "for a user with the same company with invoice" do
    let(:user) { user_of_invoice }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should_not permit(:destroy) }
  end

  context "for a admin of company" do
    let(:user) { admin_of_company }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should permit(:destroy) }
  end
end
