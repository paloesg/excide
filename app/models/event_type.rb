class EventType < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :events
  validates :name, :slug, presence: true
end
