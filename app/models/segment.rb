class Segment < ActiveRecord::Base
  belongs_to :section
  belongs_to :survey

  has_many :responses

  accepts_nested_attributes_for :responses
end
