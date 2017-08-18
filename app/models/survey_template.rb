class SurveyTemplate < ActiveRecord::Base
  include FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  has_many :survey_sections, -> { order(position: :asc) }
  has_many :surveys

  accepts_nested_attributes_for :survey_sections
end
