class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def linkedin
    auth = request.env["omniauth.auth"]
    params = request.env["omniauth.params"]

    @user = User.from_omniauth(auth, params)

    if @user.persisted?
      sign_in_and_redirect @user
      set_flash_message(:notice, :success, :kind => "Linkedin") if is_navigational_format?
    else
      session["devise.linkedin_data"] = request.env["omniauth.auth"]

      if @user.save
        profile = @user.profile.update_attributes(
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
          experience = profile.experiences.create(
            title: position.title,
            company: position.company.name,
            start_date: Date.parse('position.startDate.month + " " + position.startDate.year'),
            description: position.summary
          )
        end

        sign_in @user
        redirect_to new_account_path
      else
        redirect_to register_path(params["role"])
      end
    end
  end
end