class Segment < ApplicationRecord
  belongs_to :survey_section
  belongs_to :survey

  has_many :responses, dependent: :destroy

  accepts_nested_attributes_for :responses

  def build_responses
    l = self.responses.dup
    l << Response.new({content: ''})
    self.responses = l
  end
end
