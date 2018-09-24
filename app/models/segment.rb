class Segment < ApplicationRecord
  belongs_to :survey_section
  belongs_to :survey

  has_many :responses, dependent: :destroy

  accepts_nested_attributes_for :responses
end
