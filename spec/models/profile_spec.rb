require 'rails_helper'

RSpec.describe Profile, type: :model do
  it { should belong_to(:user) }

  it { should accept_nested_attributes_for(:user) }
end