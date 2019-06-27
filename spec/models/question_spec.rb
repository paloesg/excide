require 'rails_helper'

RSpec.describe Question, type: :model do
  it { should belong_to(:survey_section) }
  it { should have_many(:responses) }
  it { should have_and_belong_to_many(:choices) }

  it { should define_enum_for(:question_type) }
end