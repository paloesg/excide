require 'rails_helper'

RSpec.describe ActivationType, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:slug) }
  it { should validate_presence_of(:colour) }

  it { should have_many(:activations) }
end
