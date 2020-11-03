class Overture::ProfilesController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!

  def index
    @profiles = Profile.all
  end

  def show
    @profile = Profile.find(params[:id])
  end

  def state_interest
    @profile = Profile.find(params[:profile_id])
    NotificationMailer.overture_notification(current_user, @profile).deliver_later
    redirect_to overture_root_path, notice: "Thank you for stating your interest. Kindly wait for further information as we contact you through email."
  end
end
