class Outlet < ApplicationRecord
  belongs_to :franchisee
  belongs_to :company

  has_one :address, as: :addressable, dependent: :destroy

  has_many :documents, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :workflows, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy
  
  has_many_attached :photos
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
end
