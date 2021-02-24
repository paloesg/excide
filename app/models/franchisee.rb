class Franchisee < ApplicationRecord
  belongs_to :company
  belongs_to :franchisee_company, :class_name => "Company", :foreign_key => "franchisee_company_id"
  has_many :outlets, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :workflows, dependent: :destroy

  enum renewal_period_freq_unit: {days: 0, weeks: 1, months: 2, years: 3}
  enum license_type: { master_franchisee: 0, area_franchisee: 1, unit_franchisee: 2, multi_unit_franchisee: 3, sub_franchisee: 4, hybrid_franchisee: 5 }

  def check_license_type_master_or_area_or_multi_unit?
    # Check if franchise company has any children (franchisee entity) & check if franchisee is master or area franchisee (to prevent errors if it's unit franchisee)
    self.company.children.present? and (self.master_franchisee? or self.area_franchisee? or self.multi_unit_franchisee?)
  end
end
