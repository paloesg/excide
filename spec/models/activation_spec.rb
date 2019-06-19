require 'rails_helper'

RSpec.describe Activation, type: :model do
  describe "shoulda validations" do
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }

    it { should belong_to(:company) }
    it { should belong_to(:client) }
    it { should belong_to(:event_owner) }
  end
end
