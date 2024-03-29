class SurveySection < ApplicationRecord
  belongs_to :survey_template
  acts_as_list scope: :survey_template

  has_many :questions, -> { order(position: :asc) }, dependent: :destroy
  has_many :segments

  accepts_nested_attributes_for :questions, reject_if: :all_blank, allow_destroy: true

  validates :display_name, :position, :survey_template, presence: true

  has_rich_text :description
end
