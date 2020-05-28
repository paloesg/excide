class SurveyTemplate < ApplicationRecord
  include FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  has_many :survey_sections, -> { order(position: :asc) }
  has_many :surveys
  has_many :tasks

  belongs_to :company
  accepts_nested_attributes_for :survey_sections

  enum survey_type: { internal: 0, external: 1}

end
