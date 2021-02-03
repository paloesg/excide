class Overture::InvestmentsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_investment, only: [:destroy]

  def index
    # Get invested startup companies if company is the investor, vice versa
    @investments = @company.investor? ? @company.startup_investments : @company.investor_investments
    # For startups. Only can choose investor's company with contact_status Invested. The assumption here is that there is only 1 invested column in the board.
    @investor_companies = ContactStatus.find_by(name: "Invested", startup_id: @company).contacts.map(&:company) if @company.startup?
  end

  def create
    params[:investors].each do |company_id|
      @investment = Investment.create(startup_id: @company.id, investor_id: company_id)
    end
    redirect_to overture_companies_path, notice: "Investor signed."
  end

  def destroy
    @investment.destroy
    respond_to do |format|
      format.html { redirect_to overture_documents_path, notice: 'Folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_company
    @user = current_user
    @company = current_user.company
  end

  def set_investment
    @investment = Investment.find(params[:id])
  end

  def investment_params
    params.require(:investment).permit(:investor_id, :startup_id)
  end
end
