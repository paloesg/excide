require 'csv'

class User < ActiveRecord::Base
  rolify

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:linkedin]

  has_one :profile, dependent: :destroy
  has_one :address, as: :addressable
  has_many :clients
  has_many :availabilities
  has_many :allocations
  has_many :documents

  has_many :owned_events, class_name: 'Activation', foreign_key: 'event_owner_id'
  has_many :assigned_tasks, class_name: 'CompanyAction', foreign_key: 'assigned_user_id'
  has_many :completed_tasks, class_name: 'CompanyAction', foreign_key: 'completed_user_id'

  belongs_to :company

  enum bank_account_type: [:savings, :current]

  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :company, :reject_if => :all_blank, :allow_destroy => true

  after_commit :create_default_profile, if: Proc.new { self.has_role? :consultant }
  after_commit :create_default_business, if: Proc.new { self.has_role? :business }

  validates :company, presence: true

  attr_accessor :skip_validation

  include AASM

  aasm do
    state :lead, :initial => true
    state :subscribed, :expired, :cancelled

    event :make_payment do
      transitions :from => :lead, :to => :subscribed
    end

    event :cancel_subscription do
      transitions :from => :subscribed, :to => :cancelled
    end

    event :end_subscription do
      transitions :from => :subscribed, :to => :expired
    end
  end

  def self.from_omniauth(auth, params)
    logger.info auth
    logger.info params

    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.add_role params["role"].to_sym
    end
  end

  def full_name
    first_name + ' ' + last_name
  end

  def exceed_weekly_max_hours? allocation
    allocation_date = Date.parse(allocation.allocation_date.to_s)
    allocation_days = self.allocations.where(allocation_date: (allocation_date.beginning_of_week)..(allocation_date.end_of_week))

    current_hours = 0
    allocation_days.each { | a | current_hours += a.hours }
    current_hours += allocation.hours
    current_hours > self.max_hours_per_week ? false : true
  end

  def self.contractors_to_csv
    attributes = ['ID', 'First Name', 'Last Name', 'Email', 'Phone', 'NRIC', 'Date of Birth', 'Max Hours Per Week', 'Bank Name', 'Bank Account Number', 'Bank Account Type', 'Status']
    CSV.generate do |csv|
      csv << attributes
      all.each do |user|
        row = [ user.id, user.first_name, user.last_name, user.email, user.contact_number, user.nric, user.date_of_birth, user.max_hours_per_week, user.bank_name, user.bank_account_number, user.bank_account_type&.titleize, user.confirmed_at.present? ? 'Confirmed' : 'Unconfirmed' ]
        csv << row
      end
    end
  end

  def self.csv_to_contractors(file, company)
    @count = { "imported" => 0, "exist" => 0 }
    CSV.foreach(file.path, headers: true) do |row|
      @user = User.new( first_name: row['First Name'], last_name: row['Last Name'], email: row['Email'], contact_number: row['Phone'], nric: row['NRIC'], date_of_birth: row['Date of Birth'], max_hours_per_week: row['Max Hours Per Week'], bank_name: row['Bank Name'], bank_account_number: row['Bank Account Number'], bank_account_type: row['Bank Account Type']&.downcase )
      @user.company = company
      if @user.save
        @user.add_role :contractor, company
        @count['imported'] += 1
      else
        @count['exist'] += 1
      end
    end
    @count
  end

  def password_required?
    # Password is required if it is being set, but not for new records
    if !persisted?
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  def password_match?
     self.errors[:password] << "can't be blank" if password.blank?
     self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
     self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
     password == password_confirmation && !password.blank?
  end

  # new function to set the password without knowing the current
  # password used in our confirmation controller.
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  # new function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # Devise::Models:unless_confirmed` method doesn't exist in Devise 2.0.0 anymore.
  # Instead you should use `pending_any_confirmation`.
  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  private

  def create_default_profile
    if self.profile.nil?
      create_profile
    end
  end

  def create_default_business
    if self.company.nil?
      create_company
    end
  end

  def skip_validation?
    if skip_validation == true
      true
    else
      false
    end
  end
end
