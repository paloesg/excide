class SurveySection < ApplicationRecord
  belongs_to :survey_template
  acts_as_list scope: :survey_template

  has_many :questions, -> { order(position: :asc) }
  has_many :segments

  accepts_nested_attributes_for :questions

  validates :unique_name, :display_name, :position, :survey_template, presence: true
end
