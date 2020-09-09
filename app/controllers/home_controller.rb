class HomeController < ApplicationController
  # controller for the menu page for users with multiple products
  def index
    @products = current_user.company.products
  end
end
