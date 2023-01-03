class Motif::DedocoController < ApplicationController
  # before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  # Webhook from Dedoco
  def create
    puts "Returned from Dedoco"
  end
end
