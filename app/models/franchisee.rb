class Franchisee < ApplicationRecord
  has_many :outlets, dependent: :destroy
  belongs_to :company
end
