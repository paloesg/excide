class Client < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

  has_many :workflows, as: :workflowable

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true
end
