class Franchisee < ApplicationRecord  
  belongs_to :company

  has_many :documents, dependent: :destroy
  has_many :folders, dependent: :destroy
  has_many :outlets, dependent: :destroy

  enum renewal_period_freq_unit: {days: 0, weeks: 1, months: 2, years: 3}
  enum license_type: { master_franchisee: 0, area_franchisee: 1, unit_franchisee: 2}
end
