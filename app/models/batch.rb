class Batch < ApplicationRecord
  belongs_to :company
  belongs_to :template
  belongs_to :user
  has_many :workflows, dependent: :destroy

  # replacement for .first/.last because we use uuids
  def self.first
    order("batches.created_at").first
  end

  def self.last
    order("batches.created_at DESC").first
  end
end
