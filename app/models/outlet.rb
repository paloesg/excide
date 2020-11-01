class Outlet < ApplicationRecord
  belongs_to :franchisee

  has_many_attached :photos
  has_many :documents
end
