class Outlet < ApplicationRecord
  belongs_to :company

  has_one :address, as: :addressable, dependent: :destroy

  has_many :documents, dependent: :destroy
  has_many :franchisees
  has_many :users, through: :franchisees
  has_many :workflows, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy
  
  has_one_attached :header_image
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true

  enum renewal_period_freq_unit: {days: 0, weeks: 1, months: 2, years: 3}
end
