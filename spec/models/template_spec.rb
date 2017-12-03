require 'rails_helper'

RSpec.describe Template, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:slug) }
  it { should validate_presence_of(:company) }

  it { should belong_to(:company) }
  it { should have_many(:sections) }
  it { should have_many(:workflows) }
end
