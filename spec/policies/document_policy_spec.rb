require 'rails_helper'

RSpec.describe DocumentPolicy do
  subject { DocumentPolicy.new(user, document) }
  company = FactoryBot.create(:company)
  user_of_document = FactoryBot.create(:user, company: company)
  company_admin = FactoryBot.create(:company_admin, company: company)
  let(:document) { FactoryBot.create(:document, company: company, user: user_of_document) }

  context "for a user" do
    let(:user) { FactoryBot.create(:user) }
    it { should_not permit(:show) }
    it { should permit(:create) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should_not permit(:destroy) }
  end

  context "for a user with the same company with document" do
    let(:user) { user_of_document }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should_not permit(:destroy) }
  end

  context "for a admin of company" do
    let(:user) { company_admin }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should permit(:destroy) }
  end
end
