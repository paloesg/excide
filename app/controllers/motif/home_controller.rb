class Motif::HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :require_motif

  def index
  end
end
