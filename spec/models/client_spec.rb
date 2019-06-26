require 'rails_helper'

RSpec.describe Client, type: :model do
  it { should validate_presence_of(:name) }

  it { should belong_to(:company) }
  it { should belong_to(:user) }
  it { should have_many(:workflows) }
  it { should have_many(:activations) }
end
