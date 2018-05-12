class ApplicationController < ActionController::Base
  include Pundit
  include PublicActivity::StoreController
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if current_user.has_role? :admin
      stored_location_for(resource) || admin_root_path
    elsif current_user.has_role? :contractor, :any
      conductor_user_path current_user
    elsif current_user.company.present?
      symphony_root_path
    else
      root_path
    end
  end
end
