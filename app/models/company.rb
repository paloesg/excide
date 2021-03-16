class Company < ApplicationRecord
  resourcify

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

  has_one :address, as: :addressable, dependent: :destroy

  has_many :batches, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :folders, dependent: :destroy
  has_many :franchisees, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :outlets, dependent: :destroy
  has_many :recurring_workflows, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :roles, as: :resource, dependent: :destroy
  has_many :survey_templates, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :topics, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :workflows, dependent: :destroy
  has_many :workflow_actions, dependent: :destroy
  has_many :xero_contacts, dependent: :destroy
  has_many :xero_line_items, dependent: :destroy
  has_many :xero_tracking_categories, dependent: :destroy
  has_many :departments, dependent: :destroy

  # For overture association
  has_one :profile, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :contact_statuses, foreign_key: :startup_id
  has_many :investor_investments, foreign_key: :startup_id, class_name: "Investment"
  has_many :investors, through: :investor_investments
  has_many :startup_investments, foreign_key: :investor_id, class_name: "Investment"
  has_many :startups, through: :startup_investments

  has_one_attached :company_logo
  has_one_attached :profile_logo
  has_one_attached :banner_image

  has_rich_text :company_bio

  belongs_to :consultant, class_name: 'User'
  belongs_to :associate, class_name: 'User'
  belongs_to :shared_service, class_name: 'User'

  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :profile, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :contacts, :reject_if => :all_blank, :allow_destroy => true

  # enum company_type: ["Exempt Private Company Limited By Shares", "Private Company Limited By Shares", "Public Company Limited By Guarantee", "Public Company Limited By Shares", "Unlimited Exempt Private Company", "Unlimited Public Company"]

  enum company_type: { investor: 0, startup: 1 }

  enum account_type: { free_trial: 0, basic: 1, pro: 2 }

  before_create :generate_mailbox_token

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

  validates :name, presence: true, uniqueness: true
  validates :mailbox_token, uniqueness: true

  acts_as_tagger

  # Get all other companies that user has roles for excpet the current company that user belongs to
  def self.assigned_companies(user)
    user.roles.includes(:resource).map(&:resource).compact.uniq.reject{ |c| c == user.company }
  end

  def get_notes
    self.outlets.map{ |outlet| outlet.notes }.flatten.compact.uniq
  end

  def find_franchisors
    self.users.includes(:roles).where(roles: { name: "franchisor" })
  end

  # To change the settings of overture feature, we need to parse it in JSON for the admin page as the gem doesn't provide it for now
  def settings=(value)
    self[:settings] = value.is_a?(String) ? JSON.parse(value) : value
  end

  private

  def generate_mailbox_token
    # Generate friendly_token as mailbox_token for each company unless company's mailbox token already exist (loop through all companies)
    loop do
      self.mailbox_token = Devise.friendly_token.first(15).downcase
      # Break when there is no other user having the same mailbox_token
      break unless Company.where(mailbox_token: self.mailbox_token).exists?
    end
  end
end
