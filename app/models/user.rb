class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:linkedin]

  has_one :profile, dependent: :destroy

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.create_profile!(
        headline: auth.extra.raw_info.headline,
        summary: auth.extra.raw_info.summary,
        industry: auth.extra.raw_info.industry,
        specialties: auth.extra.raw_info.specialties,
        image_url: auth.extra.raw_info.pictureUrls["values"][0],
        linkedin_url: auth.extra.raw_info.publicProfileUrl,
        location: auth.extra.raw_info.location.name,
        country_code: auth.extra.raw_info.location.country.code
      )
    end
  end
end
