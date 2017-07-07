class Segment < ActiveRecord::Base
  belongs_to :section
  belongs_to :survey

  has_many :responses, dependent: :destroy

  accepts_nested_attributes_for :responses
end
