class Client < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

  has_many :workflows, as: :workflowable
  has_many :activations

  validates :name, presence: true
end
