class Overture::ProfilesController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!

  def index
    @profiles = Profile.all
  end

  def show
    @profile = Profile.find(params[:id])
  end
end
