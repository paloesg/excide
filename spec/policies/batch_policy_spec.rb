require 'rails_helper'

RSpec.describe BatchPolicy do
  subject { BatchPolicy.new(user, batch) }
  company = FactoryBot.create(:company)
  user_of_batch = FactoryBot.create(:user, company: company)
  admin_of_company = FactoryBot.create(:company_admin, company: company)
  let(:batch) { FactoryBot.create(:batch, user: user_of_batch, company: company) }

  context "for a user" do
    let(:user) { FactoryBot.create(:user) }
    it { should permit(:index) }
    it { should_not permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should_not permit(:destroy) }
  end

  context "for a user with company" do
    let(:user) { user_of_batch }
    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should_not permit(:destroy) }
  end

  context "for a admin of company" do
    let(:user) { admin_of_company }
    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should permit(:destroy) }
  end
end
