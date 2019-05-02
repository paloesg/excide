class Batch < ApplicationRecord
  belongs_to :company
  belongs_to :template
  has_many :workflows
end
