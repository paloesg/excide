class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  layout 'symphony/application', only: :edit

  # GET /resource/sign_up
  def new
    if (params[:product] == "symphony" || params[:product] == "ada" || params[:product] == "overture")
      @user = User.new
      @user.build_company
    else
      raise ActionController::RoutingError.new('Invalid Product Name in URL')
    end
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    if params[:company].present?
      resource.company = Company.friendly.find(params[:company])
      # Set to pro for normal franchise management usage
      resource.company.account_type = 2
    else
      # Company is optional when signing up to ADA. In case of this, we create a default company with their name in it
      if resource.company.nil?
        resource.company = Company.create(name: resource.full_name)
      end
      # Set company to basic plan for now
      resource.company.account_type = 1
      resource.company.products = ["motif"]
      # By default, set company storage limit to 2Gb upon creation
      resource.company.storage_limit = 2147483648
      if resource.save
        if resource.company.save
          set_company_roles(resource, params[:sign_up])
        end
      end
    end
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        sign_in(resource_name, resource)
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit
    set_contact
    super
  end

  # PUT /resource
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    # if(params[:user][:stripe_card_token])
    #   customer = Stripe::Customer.create({email: current_user.email, card: params[:user][:stripe_card_token]})
    #   resource.stripe_customer_id = customer.id
    # end
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      # gsub(/\D/, "") keeps only the numbers which is the country code
      self.resource.contact_number = params[:country_code].gsub(/\D/, "") + params[:contact]
      if Phonelib.parse(self.resource.contact_number).valid?
        self.resource.save
        set_flash_message_for_update(resource, prev_unconfirmed_email)
        bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
        respond_with resource, location: edit_user_registration_path
      else
        redirect_to edit_user_registration_path
        flash[:alert] = "Invalid Contact Number"
      end
    else
      set_contact
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  def additional_information
    build_addresses
    @user = current_user
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :contact_number])
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :contact_number, :company_id, :email, :password, :password_confirmation, :current_password, :stripe_card_token, :stripe_customer_id)
  end

  # The path used after sign up.
  def after_sign_up_path_for(_resource)
    "/motif/contacts"
  end

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :contact_number, :company_id, :email, :password, :password_confirmation, :current_password, :stripe_card_token, :stripe_customer_id, company_attributes:[:id, :name, :website_url])
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
    # super(resource)
    # symphony_root_path
  # end

  def build_addresses
    @company = current_user.company
    if @company.address.blank?
      @company.address = @company.build_address
    end
  end

  # As country code and contact are displayed as tags in the edit page, user[contact_number] is not used in the edit and update and country code and contact field have to be manually set in controller.
  def set_contact
    @contact = Phonelib.parse(@user.contact_number)
    if @contact.valid?
      @country_code = @contact.country_code
      @contact = @user.contact_number.remove(@country_code)
      @country = Country.find_country_by_country_code(@country_code).iso_short_name + " (+" + @country_code + ")"
    elsif @user&.company&.address&.country.present?
      @country = @user.company.address.country + " (+" + Country.find_country_by_name(@user.company.address.country).country_code + ")"
    else
      @country = nil;
    end
  end

  def set_company_roles(resource, role=nil)
    if role == "franchisor"
      resource.add_role(:franchisor_free, resource.company)
    else
      # Set franchisee or franchisor roles for listing
      resource.add_role(role.to_sym, resource.company)
    end
  end
end
