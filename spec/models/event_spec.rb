require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "shoulda validations" do
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:client) }
    it { should validate_presence_of(:event_type) }

    it { should belong_to(:company) }
    it { should belong_to(:client) }
    it { should belong_to(:staffer) }
    it { should belong_to(:event_type) }

    it { should have_one(:address) }

    it { should have_many(:allocations) }

    it { should accept_nested_attributes_for(:address) }
  end
end
