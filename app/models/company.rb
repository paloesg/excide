class Company < ActiveRecord::Base
  resourcify

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

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

  has_many :users
  has_many :projects, dependent: :destroy
  has_many :documents
  has_many :templates
  has_many :workflows
  has_many :company_actions
  has_many :clients
  has_one :address, as: :addressable

  accepts_nested_attributes_for :projects, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true

  enum company_type: ["Exempt Private Company Limited By Shares", "Private Company Limited By Shares", "Public Company Limited By Guarantee", "Public Company Limited By Shares", "Unlimited Exempt Private Company", "Unlimited Public Company"]
end
