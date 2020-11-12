class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception

  include Adapter
  include Pundit
  include PublicActivity::StoreController

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  #TokenInvalid in case user is still using public app for xero. It will redirect them to xero authorization page
  rescue_from Xeroizer::OAuth::TokenInvalid, Xeroizer::OAuth::TokenExpired, with: :xero_login
  #If record is not found on xero, it will return flash message as string
  rescue_from Xeroizer::RecordInvalid, URI::InvalidURIError, with: :xero_error
  #Error occurs for eg, the tax rate doesn't match with account code. Xero returns an exception in XML, hence the need to parse it truncate it in the xero_error_api_exception method
  rescue_from Xeroizer::ApiException, with: :xero_error_api_exception
  rescue_from OAuth::Unauthorized, with: :xero_unauthorized
  rescue_from Xeroizer::OAuth::RateLimitExceeded, with: :xero_rate_limit_exceeded

  before_action :authenticate_product

  after_action :store_location

  def store_location
    # store last url as long as it isn't a /users path
    session[:previous_url] = request.fullpath unless request.xhr? or request.fullpath =~ /\/users/
  end

  def after_sign_in_path_for(resource)
    if current_user.company.products.count == 1
      # Path after sign in is the product's root path
      '/' + current_user.company.products.first
    elsif current_user.has_role?(:investor, current_user.company)
      overture_root_path
    else
      root_path
    end
  end

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:alert] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_back(fallback_location: root_path)
  end

  def xero_login
    @xero_client = Xeroizer::PartnerApplication.new(ENV["XERO_CONSUMER_KEY"], ENV["XERO_CONSUMER_SECRET"], "| echo \"#{ENV["XERO_PRIVATE_KEY"]}\" ")
    request_token = @xero_client.request_token(oauth_callback: ENV['ASSET_HOST'] + '/xero_callback_and_update')
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to request_token.authorize_url
  end

  def xero_error(e)
    message = 'Xero returned an error - ' + e.message + '. Please ensure you have filled in all the required data in the right format.'
    Rails.logger.error("Xero error: #{message}")
    redirect_to session[:previous_url], alert: message
  end

  #prevent overflow cookie errors by parsing and truncating the XML exception xero returns
  def xero_error_api_exception(e)
    message = 'Xero returned an API error - ' + e.parsed_xml.text.to_s.truncate(200) + '. Please ensure you have filled in all the required data in the right format.'
    Rails.logger.error("Xero API error: #{message}")
    redirect_to session[:previous_url], alert: message
  end

  def xero_unauthorized(e)
    message = 'Xero authorization failed - ' + CGI.unescape(e.request.body)
    Rails.logger.error("Xero OAuth error: #{message}")
    redirect_to session[:previous_url], alert: message
  end

  def xero_rate_limit_exceeded
    message = 'You have exceeded the number of times you can access Xero in 1 minute. Please wait a few minutes and try again.'
    Rails.logger.error("Xero error: Rate limited exceeded")
    redirect_to symphony_root_path, alert: message
  end

  # Checks the controller parent and check if the user has access to the product based on application policy unless parent is users (login) or object (not namespaced)
  def authenticate_product
    product = self.class.parent.to_s.downcase
    authorize current_user, ("has_" + product + "?").to_sym unless product == "users" || "object"
  end

  def set_company
    @user = current_user
    @company = current_user.company
  end
end
