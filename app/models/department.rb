class Department < ApplicationRecord
  belongs_to :company
  has_many :users
  has_many :events
end
