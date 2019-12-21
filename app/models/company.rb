class Company < ApplicationRecord
  resourcify

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

  has_many :users, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :workflows, dependent: :destroy
  has_many :recurring_workflows, dependent: :destroy
  has_many :workflow_actions, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :batches, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :xero_contacts, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy

  belongs_to :consultant, class_name: 'User'
  belongs_to :associate, class_name: 'User'
  belongs_to :shared_service, class_name: 'User'

  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true

  enum company_type: ["Exempt Private Company Limited By Shares", "Private Company Limited By Shares", "Public Company Limited By Guarantee", "Public Company Limited By Shares", "Unlimited Exempt Private Company", "Unlimited Public Company"]

  enum account_type: { free_trial: 0, basic: 1, pro: 2 }

  include AASM

  aasm column: :account_type, enum: true do
    state :free_trial, initial: true
    state :basic
    state :pro

    event :trial_ends do
      transitions from: :free_trial, to: :basic
    end

    event :upgrade do
      transitions from: [:free_trial, :basic], to: :pro
    end

    event :downgrade do
      transitions from: :pro, to: :basic
    end
  end

  enum gst_quarter: { mar_jun_sep_dec: 0, apr_jul_oct_jan: 1, may_aug_nov_feb: 2}

  validates :name, presence: true, on: :additional_information

  # Get all other companies that user has roles for excpet the current company that user belongs to
  def self.assigned_companies(user)
    user.roles.includes(:resource).map(&:resource).compact.uniq.reject{ |c| c == user.company }
  end

  def trial_ended
    if self.trial_end_date.present? and self.trial_end_date < DateTime.current
      self.trial_ends unless self.pro? or self.basic? #only from free trial to basic
    end
  end
end
