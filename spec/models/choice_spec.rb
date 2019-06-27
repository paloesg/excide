require 'rails_helper'

RSpec.describe Choice, type: :model do
  it { should have_and_belong_to_many(:questions) }
  it { should have_many(:responses) }
end