class Business < ActiveRecord::Base
  belongs_to :user

  has_many :projects, dependent: :destroy

  accepts_nested_attributes_for :projects, :reject_if => :all_blank, :allow_destroy => true

  enum company_type: [:public_company, :educational, :self_employed, :government_agency, :non_profit, :self_owned, :privately_held, :partnership]
end
