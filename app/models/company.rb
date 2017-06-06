class Company < ActiveRecord::Base
  include AASM

  aasm do
    state :lead, :initial => true
    state :registered, :paid, :name_reserved, :incorporated, :nominated_corp_sec

    event :submit_details do
      transitions :from => :lead, :to => :registered
    end

    event :make_payment do
      transitions :from => :registerd, :to => :paid
    end

    event :reserve_name do
      transitions :from => :paid, :to => :name_reserved
    end

    event :incorporate do
      transitions :from => :name_reserved, :to => :incorporated
    end

    event :nominate_corp_sec do
      transitions :from => :incorporated, :to => :nominated_corp_sec
    end
  end

  belongs_to :user

  has_many :projects, dependent: :destroy

  accepts_nested_attributes_for :projects, :reject_if => :all_blank, :allow_destroy => true

  enum company_type: [:public_company, :educational, :self_employed, :government_agency, :non_profit, :self_owned, :privately_held, :partnership]
end
