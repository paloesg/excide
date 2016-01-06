class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if current_user.agree_terms != true
      new_account_path
    elsif current_user.has_role? :consultant
      profile_path
    elsif current_user.has_role? :business
      new_project_path
    else
      root_path
    end
  end
end
