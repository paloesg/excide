require 'rails_helper'

RSpec.describe SurveySection, type: :model do
  it { should validate_presence_of(:unique_name) }
  it { should validate_presence_of(:display_name) }
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:survey_template) }

  it { should belong_to(:survey_template) }
  it { should have_many(:questions) }
  it { should have_many(:segments) }

  it { should accept_nested_attributes_for (:questions) }
end
