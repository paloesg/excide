require 'rails_helper'

RSpec.describe TemplatePolicy, type: :policy do
  subject { TemplatePolicy.new(user, template) }
  let(:template) { FactoryBot.create(:template) }

  context "for an admin" do
    let(:user) { FactoryBot.create(:user) }
    it { should_not permit(:index) }
    it { should_not permit(:create) }
    it { should_not permit(:new) }
    it { should_not permit(:update) }
    it { should_not permit(:edit) }
    it { should_not permit(:create_section) }
    it { should_not permit(:destroy_section ) }
  end

  context "for an admin" do
    let(:user) { FactoryBot.create(:company_admin) }
    it { should permit(:index) }
    it { should permit(:create) }
    it { should permit(:new) }
    it { should permit(:update) }
    it { should permit(:edit) }
    it { should permit(:create_section) }
    it { should permit(:destroy_section ) }
  end
end
