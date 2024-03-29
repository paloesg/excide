class Overture::ProfilesController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  after_action :verify_authorized

  def index
    authorize Profile
    @profiles = policy_scope(Profile)
    @profiles = Kaminari.paginate_array(@profiles).page(params[:page]).per(5)
    # Filter contacts that are searchable true
    @public_key = Algolia.generate_secured_api_key(ENV['ALGOLIASEARCH_API_KEY_SEARCH'], {filters: ''})
  end

  def show
    @profile = Profile.find(params[:id])
    authorize @profile
    @topic = Topic.new
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
