class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if current_user.agree_terms != true
      new_account_path
    elsif current_user.has_role? :admin
      admin_root_path
    elsif current_user.has_role? :consultant
      profile_path
    elsif current_user.has_role? :business
      if current_user.business.projects.present?
        business_projects_path
      else
        new_business_project_path
      end
    else
      root_path
    end
  end
end
