class Overture::InvestmentsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  def create
    params[:investors].each do |company_id|
      @investment = Investment.create(startup_id: @company.id, investor_id: company_id)
    end
    redirect_to overture_companies_path, notice: "Investor signed."
  end

  private

  def set_company
    @user = current_user
    @company = current_user.company
  end

  def investment_params
    params.require(:investment).permit(:investor_id, :startup_id)
  end
end
