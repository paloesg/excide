class Overture::InvestmentsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_investment, only: [:destroy]

  def index
    # Get investments from either startup or investor
    @investments = @company.investor? ? @company.startup_investments : @company.investor_investments
    # For startups. Only can choose investor's company with contact_status Invested. The assumption here is that there is only 1 invested column in the board.
    @investor_companies = Company.includes(:contacts).where(company_type: "investor", contacts: {cloned_by: @company}) if @company.startup?
    @user = User.new
  end

  def create
    authorize([:overture, Investment])
    @investment = Investment.new(startup_id: @company.id, investor_id: params[:investor_id])
    respond_to do |format|
      if @investment.save
        format.html { redirect_to overture_investments_path, notice: 'Successfully signed an investor.' }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      else
        format.json { render json: @investment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @investment.destroy
    respond_to do |format|
      format.html { redirect_to overture_investments_path, notice: 'Folder was successfully destroyed.' }
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
