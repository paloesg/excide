class Response < ApplicationRecord
  belongs_to :question
  belongs_to :choice
  belongs_to :segment

  has_one_attached :file

  # replacement for .first/.last because we use uuids
  def self.first
    order("responses.created_at").first
  end

  def self.last
    order("responses.created_at DESC").first
  end
end
