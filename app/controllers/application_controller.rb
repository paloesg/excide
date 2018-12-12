class ApplicationController < ActionController::Base
  include Pundit
  include PublicActivity::StoreController
  protect_from_forgery with: :exception

  after_action :store_location

  def store_location
    # store last url as long as it isn't a /users path
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/
  end

  def after_sign_in_path_for(resource)
    if current_user.has_role? :superadmin
      stored_location_for(resource) || admin_root_path
    elsif current_user.has_role? :contractor, :any
      conductor_user_path current_user
    elsif current_user.company.present?
      symphony_root_path
    else
      session[:previous_url] || root_path
    end
  end
end
