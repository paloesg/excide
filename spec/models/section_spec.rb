require 'rails_helper'

RSpec.describe Section, type: :model do
  it { should validate_presence_of(:section_name) }
  it { should validate_presence_of(:position) }

  it { should belong_to(:template) }
  it { should have_many(:tasks) }
end
