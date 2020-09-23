class Motif::HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :require_motif

  def index
  end

  private

  # checks if the user's company has Motif. Links to motif_policy.rb
  def require_motif
    authorize :motif, :index?
  end
end
