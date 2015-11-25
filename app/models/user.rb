class User < ActiveRecord::Base
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:linkedin]

  has_one :profile, dependent: :destroy

  before_create :build_default_profile

  def self.from_omniauth(auth, params)
    logger.info auth
    logger.info params

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.add_role params["role"].to_sym

      profile = user.create_profile!(
        headline: auth.extra.raw_info.headline,
        summary: auth.extra.raw_info.summary,
        industry: auth.extra.raw_info.industry,
        specialties: auth.extra.raw_info.specialties,
        image_url: auth.extra.raw_info.pictureUrls["values"][0],
        linkedin_url: auth.extra.raw_info.publicProfileUrl,
        location: auth.extra.raw_info.location.name,
        country_code: auth.extra.raw_info.location.country.code
      )

      unless auth.extra.raw_info.positions["_total"] == 0
        position = auth.extra.raw_info.positions["values"][0]
        experience = profile.experiences.create!(
          title: position.title,
          company: position.company.name,
          start_date: Date.parse('position.startDate.month + " " + position.startDate.year'),
          description: position.summary
        )
      end
    end
  end

  private

  def build_default_profile
    build_profile
    true
  end
end
