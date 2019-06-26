require 'rails_helper'

RSpec.describe Allocation, type: :model do
  it { should validate_presence_of(:start_time) }
  it { should validate_presence_of(:end_time) }
  it { should validate_presence_of(:activation) }
  it { should validate_presence_of(:allocation_type) }
  it { should validate_presence_of(:allocation_date) }

  it { should belong_to(:user) }
  it { should belong_to(:activation) }

  it { should define_enum_for(:allocation_type)}
end
