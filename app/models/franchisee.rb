class Franchisee < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  
  belongs_to :company
  belongs_to :user
  belongs_to :outlet

  has_one_attached :profile_picture
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :user, :reject_if => :all_blank, :allow_destroy => true
end
