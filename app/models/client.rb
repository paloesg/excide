class Client < ApplicationRecord
  belongs_to :user
  belongs_to :company

  has_many :workflows, as: :workflowable
  has_many :events

  validates :name, presence: true
end