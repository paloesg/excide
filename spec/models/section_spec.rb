require 'rails_helper'

RSpec.describe Section, type: :model do

  it { should belong_to(:template) }
  it { should have_many(:tasks) }
  it { should accept_nested_attributes_for (:tasks) }
end
