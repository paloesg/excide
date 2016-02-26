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

      # User creation in process, skip validations for now
      @user.skip_validation = true

      # Skip email confirmation for users that signed up through LinkedIn
      @user.skip_confirmation!

      if @user.save
        if @user.has_role? :consultant
          @user.create_profile(
            headline: auth.extra.raw_info.headline,
            summary: auth.extra.raw_info.summary,
            industry: auth.extra.raw_info.industry,
            specialties: auth.extra.raw_info.specialties,
            image_url: auth.extra.raw_info.pictureUrls["values"].try(:[], 0),
            linkedin_url: auth.extra.raw_info.publicProfileUrl,
            location: auth.extra.raw_info.location.name,
            country_code: auth.extra.raw_info.location.country.code
          )

          unless auth.extra.raw_info.positions["_total"] == 0
            position = auth.extra.raw_info.positions["values"][0]
            experience = @user.profile.experiences.create(
              title: position.title,
              company: position.company.name,
              start_date: Date.parse('position.startDate.month + " " + position.startDate.year'),
              description: position.summary
            )
          end
        elsif @user.has_role? :business
          unless auth.extra.raw_info.positions["_total"] == 0
            position = auth.extra.raw_info.positions["values"][0]
            @user.create_business(
              name: position.company.name,
              title: position.title,
              industry: position.company.industry,
              company_type: position.company.type.try(:parameterize).try(:underscore),
              description: position.summary,
              linkedin_url: auth.extra.raw_info.publicProfileUrl
            )
          end
        end

        # User creation complete, require validation
        @user.skip_validation = false

        sign_in @user
        redirect_to new_account_path
      else
        redirect_to register_path(params["role"])
      end
    end
  end
end