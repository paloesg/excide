class Overture::InvestmentsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!

  def create
    @profile = Profile.find_by(id: params[:profile])
    @investor = @profile.company
    @startup = current_user.company
    @investment = Investment.new(investor_id: @investor.id, startup_id: @startup.id)
    if @investment.save
      redirect_to overture_profile_path(@profile), notice: "Investor successfully added."
    else
      redirect_to overture_root_path, alert: "Error occurs when added investor company."
    end
  end

  private
  def investment_params
    params.require(:investment).permit(:investor_id, :startup_id)
  end
end
