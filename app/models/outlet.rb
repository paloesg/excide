class Outlet < ApplicationRecord
  belongs_to :franchisee

  has_many_attached :photos
end
