class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Pundit
  include PublicActivity::StoreController

  rescue_from Pundit::NotAuthorizedError, Pundit::AuthorizationNotPerformedError, with: :user_not_authorized

  after_action :store_location

  def store_location
    # store last url as long as it isn't a /users path
    session[:previous_url] = request.fullpath unless request.xhr? or request.fullpath =~ /\/users/
  end

  def after_sign_in_path_for(resource)
    connect_xero_organisation
    
    # if current_user.has_role? :superadmin
    #   # stored_location_for(resource) || admin_root_path
    # elsif current_user.has_role? :contractor, :any
    #   conductor_user_path current_user
    # elsif current_user.has_role? :shared_service, :any
    #   symphony_batches_path
    # elsif current_user.company.present?
    #   symphony_root_path
    # else
    #   session[:previous_url] || root_path
    # end
  end

  def current_user
    # Overwrite devise current_user function to eager load roles for current user
    @current_user ||= super && User.includes(roles: [:resource]).where(id: @current_user.id).first
  end

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:alert] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to symphony_root_path
  end

  def connect_xero_organisation  
    @xero_client = Xeroizer::PartnerApplication.new(ENV["XERO_CONSUMER_KEY"], ENV["XERO_CONSUMER_SECRET"], "xero-privatekey.pem")
    request_token = @xero_client.request_token(oauth_callback: "http://localhost:3000/xero_session_callback")
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    request_token.authorize_url
  end
end
