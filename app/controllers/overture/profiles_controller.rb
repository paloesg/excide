class Overture::ProfilesController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
    # if params[:list] == "Startup"
    #   @profiles = Profile.tagged_with("Startup")
    # elsif params[:list] == "SME"
    #   @profiles = Profile.tagged_with("SME")
    # else
    #   @profiles = Profile.all
    # end
    @profiles = Profile.includes(:company).where(companies: { company_type: params[:search_type] })
    @profiles = Kaminari.paginate_array(@profiles).page(params[:page]).per(5)
  end

  def show
    @profile = Profile.find(params[:id])
    @topic = Topic.new
  end

  def state_interest
    @profile = Profile.find(params[:profile_id])
    NotificationMailer.overture_notification(current_user, @profile).deliver_later
    redirect_to overture_root_path, notice: "Thank you for stating your interest. Kindly wait for further information as we contact you through email."
  end

  private
  def set_company
    @user = current_user
    @company = current_user.company
  end

  def profile_params
    params.require(:profile).permit(:id, :name, :url, :company_id, :profile_logo, :company_information)
  end
end
