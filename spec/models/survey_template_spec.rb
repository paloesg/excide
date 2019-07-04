require 'rails_helper'

RSpec.describe SurveyTemplate, type: :model do
  it { should have_many(:survey_sections) }
  it { should have_many(:surveys) }

  it { should accept_nested_attributes_for(:survey_sections) }
  it { should define_enum_for(:survey_type) }
end