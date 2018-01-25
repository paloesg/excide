class Conductor::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!

  def show
  end

  private

end
