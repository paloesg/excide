class ApplicationController < ActionController::Base
  include Pundit
  include PublicActivity::StoreController
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if current_user.has_role? :admin
      admin_root_path
    elsif current_user.has_role? :temp_staff, :any
      conductor_user_path
    elsif current_user.company.present?
      symphony_root_path
    elsif current_user.lead?
      new_account_path
    elsif current_user.has_role? :consultant
      profile_path
    elsif current_user.has_role? :company
      dashboard_path
    else
      root_path
    end
  end
end
