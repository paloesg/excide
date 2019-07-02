require 'rails_helper'

RSpec.describe Reminder, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:company) }
  it { should belong_to(:task) }
  it { should belong_to(:workflow_action) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:company) }
  it { should validate_presence_of(:title) }

  it { should define_enum_for(:freq_unit) }
end