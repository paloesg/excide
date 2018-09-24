class ActivationType < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :activations
  validates :name, :slug, :colour, presence: true
end
