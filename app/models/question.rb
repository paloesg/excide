class Question < ApplicationRecord
  belongs_to :survey_section
  acts_as_list scope: :survey_section

  has_many :responses

  has_and_belongs_to_many :choices

  enum question_type: { text: 0, number: 1, single: 2, multiple: 3, file: 4}
end
