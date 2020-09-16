class HomeController < ApplicationController
  # controller for the menu page for users with multiple products
  def index
    if current_user.present?
      @products = current_user.company.products
    else
      redirect_to new_user_session_path
    end
  end
end
