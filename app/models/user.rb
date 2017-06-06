class User < ActiveRecord::Base
  rolify

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:linkedin]

  has_one :profile, dependent: :destroy
  has_one :company, dependent: :destroy

  after_commit :create_default_profile, if: Proc.new { self.has_role? :consultant }
  after_commit :create_default_business, if: Proc.new { self.has_role? :business }

  validates :first_name, presence: true, unless: :skip_validation?
  validates :last_name, presence: true, unless: :skip_validation?
  validates :contact_number, presence: true, unless: :skip_validation?
  validates :allow_contact, inclusion: { in: [true] }, unless: :skip_validation?
  validates :agree_terms, inclusion: { in: [true] }, unless: :skip_validation?

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

  private

  def create_default_profile
    if self.profile.nil?
      create_profile
    end
  end

  def create_default_business
    if self.companay.nil?
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
