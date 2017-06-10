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
  has_one :address, as: :addressable

  accepts_nested_attributes_for :projects, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :address

  enum company_type: [:exempt_private_company_limited_by_shares, :private_company_limited_by_shares, :public_company_limited_by_guarantee, :public_company_limited_by_shares, :unlimited_exempt_private_company, :unlimited_public_company]
end
