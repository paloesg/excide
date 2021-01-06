class Franchisee < ApplicationRecord  
  belongs_to :company
  has_many :outlets, dependent: :destroy
  has_many :documents, dependent: :destroy

  enum renewal_period_freq_unit: {days: 0, weeks: 1, months: 2, years: 3}
  enum license_type: { master_franchisee: 0, area_franchisee: 1, unit_franchisee: 2}

  def check_license_type_master_or_area?
    # Check if franchise company has any children (franchisee entity) & check if franchisee is master or area franchisee (to prevent errors if it's unit franchisee)
    self.company.children.present? and (self.master_franchisee? or self.area_franchisee?)
  end
end
