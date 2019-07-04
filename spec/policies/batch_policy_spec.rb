require 'rails_helper'

RSpec.describe BatchPolicy do
  subject { BatchPolicy.new(user, batch) }
  let(:batch) { FactoryBot.create(:batch) }

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
end
