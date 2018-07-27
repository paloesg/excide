class ActivationType < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug, use: [:slugged, :finders]

  has_one :activation
  validates :name, :slug, :colour, presence: true
end
