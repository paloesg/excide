class SurveyTemplate < ApplicationRecord
  include FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  has_many :survey_sections, -> { order(position: :asc) }
  has_many :surveys

  belongs_to :company
  accepts_nested_attributes_for :survey_sections

  enum survey_type: [:corp_sec_request, :financial_model]
end
