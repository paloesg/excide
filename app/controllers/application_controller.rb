class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if current_user.has_role? :consultant
      profile_path
    elsif current_user.has_role? :business
      business_path
    end
  end
end
