class Outlet < ApplicationRecord
  belongs_to :franchisee

  has_one :address, as: :addressable, dependent: :destroy

  has_many :documents
  has_many :users
  has_many :workflows
  has_many_attached :photos
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
end
