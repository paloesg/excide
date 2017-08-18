class SurveySection < ActiveRecord::Base
  belongs_to :survey_template
  acts_as_list scope: :survey_template

  has_many :questions, -> { order(position: :asc) }
  has_many :segments

  accepts_nested_attributes_for :questions
end
