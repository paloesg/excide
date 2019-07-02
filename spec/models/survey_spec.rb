require 'rails_helper'

RSpec.describe Survey, type: :model do
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:survey_template) }
  it { should validate_presence_of(:title) }

  it { should belong_to(:user) }
  it { should belong_to(:company) }
  it { should belong_to(:survey_template) }
  it { should have_many(:segments) }

  it { should accept_nested_attributes_for (:company) }
end
