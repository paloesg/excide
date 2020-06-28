class Client < ApplicationRecord
  belongs_to :user
  belongs_to :company

  has_many :workflows, as: :workflowable
  has_many :events

  validates :name, presence: true

  # Tagging documents to indicate where document is created from
  acts_as_taggable_on :tags
end
