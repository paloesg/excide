require 'rails_helper'

RSpec.describe Segment, type: :model do
  it { should belong_to(:survey_section) }
  it { should belong_to(:survey) }

  it { should have_many(:responses) }
  it { should accept_nested_attributes_for (:responses) }

end