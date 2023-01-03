class Motif::DedocoController < ApplicationController
  before_action :authenticate_user!

  # Webhook from Dedoco
  def create
    puts "Returned from Dedoco"
  end
end
