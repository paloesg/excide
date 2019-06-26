require 'rails_helper'

RSpec.describe Availability, type: :model do
  it { should validate_presence_of(:start_time) }
  it { should validate_presence_of(:end_time) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:available_date) }

  it { should belong_to(:user) }

end
