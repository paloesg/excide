require 'rails_helper'

RSpec.describe DocumentPolicy do
  subject { DocumentPolicy.new(user, document) }
  let(:document) { FactoryBot.create(:document) }

  context "for a user" do
    let(:user) { FactoryBot.create(:user) }
    it { should_not permit(:show) }
  end
end
