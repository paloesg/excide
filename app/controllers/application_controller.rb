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
    if current_user.company.connect_xero?
      XeroSessionsController.connect_to_xero(session)
    else
      symphony_root_path
    end
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
end
