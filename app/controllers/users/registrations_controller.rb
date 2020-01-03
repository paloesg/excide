class Users::RegistrationsController < Devise::RegistrationsController
  layout :multi_layout

  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    if params[:company].present?
      resource.company = Company.friendly.find(params[:company])
    else
      company = Company.new()
      company.save
      resource.company = company
    end
    resource.save
    role = params[:role].present? ? params[:role] : "admin"
    if resource.company.present?
      resource.add_role role.to_sym, resource.company
    else
      resource.add_role role.to_sym
    end
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        SlackService.new.user_signup(resource).deliver
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
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if(params[:user][:stripe_card_token])
      customer = Stripe::Customer.create({email: current_user.email, card: params[:user][:stripe_card_token]})
      resource.stripe_customer_id = customer.id
    end

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      respond_with resource, location: after_update_path_for(resource)
    else
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
    render layout: 'stack/application'
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :contact_number])
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :stripe_card_token, :stripe_customer_id)
  end

  # The path used after sign up.
  def after_sign_up_path_for(_resource)
    additional_information_path
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

  def multi_layout
    case action_name
    when "new", "additional_information"
      "application"
    else
      "dashboard/application"
    end
  end
end
