class Motif::HomeController < ApplicationController
  layout 'motif/application'

  before_action :authenticate_user!

  def index
  end
end
