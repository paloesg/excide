class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  def show
  end

  def edit
    build_experiences_and_qualifications
  end

  def create
    @profile = Profile.new(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: 'Profile was successfully updated.'
    else
      build_experiences_and_qualifications
      render :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @user = current_user
      @profile = @user.profile
      @experiences = @profile.experiences
      @qualifications = @profile.qualifications
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(
        :id, :headline, :summary, :industry, :specialties, :location, :country_code,
        experiences_attributes: [:id, :title, :company, :start_date, :end_date, :description, :_destroy],
        qualifications_attributes: [:id, :title, :institution, :year_obtained, :description, :_destroy]
      )
    end

    def build_experiences_and_qualifications
      if @experiences.blank?
        @experiences.build
      end

      if @qualifications.blank?
        @qualifications.build
      end
    end
end
