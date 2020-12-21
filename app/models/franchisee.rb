class Franchisee < ApplicationRecord  
  belongs_to :company
  # belongs_to :user
  has_many :outlets, dependent: :destroy

  # accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
  # accepts_nested_attributes_for :user, :reject_if => :all_blank, :allow_destroy => true
  enum renewal_period_freq_unit: {days: 0, weeks: 1, months: 2, years: 3}
end
