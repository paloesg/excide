require 'rails_helper'

RSpec.describe DocumentPolicy do
  subject { DocumentPolicy.new(user, document) }
  company = FactoryBot.create(:company)
  user_of_document = FactoryBot.create(:user, company: company)
  admin_of_company = FactoryBot.create(:company_admin, company: company)
  let(:document) { FactoryBot.create(:document, company: company, user: user_of_document, file_url: "//excide-platform-staging.s3.ap-southeast-1.amazonaws.com/uploads/f0b05221-8ca7-47bc-a4d9-d3804670a79d/invoice-eg-4.pdf") }

  context "for a user" do
    let(:user) { FactoryBot.create(:user) }
    it { should permit(:index) }
    it { should_not permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should permit(:index_create) }
    it { should permit(:index_create) }
    it { should permit(:multiple_edit) }
    it { should_not permit(:destroy) }
  end

  context "for a user with the same company with document" do
    let(:user) { user_of_document }
    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should permit(:index_create) }
    it { should permit(:index_create) }
    it { should permit(:multiple_edit) }
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
    it { should permit(:index_create) }
    it { should permit(:index_create) }
    it { should permit(:multiple_edit) }
    it { should permit(:destroy) }
  end
end
