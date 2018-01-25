class User < ActiveRecord::Base
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

  rolify

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:linkedin]

  has_one :profile, dependent: :destroy
  has_one :address, as: :addressable
  has_many :clients
  has_many :activations

  has_many :company_actions

  belongs_to :company

  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :company, :reject_if => :all_blank, :allow_destroy => true

  after_commit :create_default_profile, if: Proc.new { self.has_role? :consultant }
  after_commit :create_default_business, if: Proc.new { self.has_role? :business }

  validates :company, presence: true

  attr_accessor :skip_validation

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
