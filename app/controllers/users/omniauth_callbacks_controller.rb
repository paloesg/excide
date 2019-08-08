class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def xero
    auth = request.env["omniauth.auth"]

    session[:xero_auth] = {
      access_token: auth.credentials.token,
      access_key:   auth.credentials.secret,
      session_handle: auth.credentials.session_handle,
      expires_at: auth.credentials.expires_at
    }
    #save company's xero details
    company = current_user.company
    company.access_key = session[:xero_auth][:access_key]
    company.access_secret = session[:xero_auth][:access_token]
    company.session_handle = session[:xero_auth][:session_handle]
    company.expires_at = session[:xero_auth][:expires_at]
    company.save
    set_flash_message(:notice, :success, :kind => "Xero")
    redirect_to session[:previous_url]
  end

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
        elsif @user.has_role? :business
          unless auth.extra.raw_info.positions["_total"] == 0
            position = auth.extra.raw_info.positions["values"][0]
            @user.create_company(
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