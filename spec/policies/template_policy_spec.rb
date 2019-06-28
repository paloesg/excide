require 'rails_helper'

RSpec.describe TemplatePolicy, type: :policy do
  subject { described_class }
  let(:company) { Company.new }
  let(:user) { FactoryBot.create(:company_admin) }

  permissions :index? do
    it "denies access if user is non-admin" do
      @user = user.add_role(:admin, user)
      expect(subject).to permit(@user)
    end
  end
end
