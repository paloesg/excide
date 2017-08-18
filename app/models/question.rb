class Question < ActiveRecord::Base
  belongs_to :survey_section
  acts_as_list scope: :survey_section

  has_many :responses

  has_and_belongs_to_many :choices

  enum question_type: [:text, :number, :single, :multiple, :file]
end
