class Motif::OutletsController < ApplicationController
  before_action :set_company

  def index
    @outlets = Outlet.includes(:company).where(companies: { franchise_id: @company.id })
    @outlet = Outlet.new
  end

  def create
    @outlet = Outlet.new(outlet_params)
    # Setting the outlet to the franchisee
    @outlet.company = Company.find_by(id: params[:company_id])
    # Setting the franchisee to the franchise company
    @outlet.company.franchise_id = @company.id
    respond_to do |format|
      if @outlet.save and @outlet.company.save
        format.html { redirect_to motif_companies_path, notice: 'Outlet was successfully created.' }
        format.json { render :show, status: :created, location: @outlet }
      else
        format.html { render :new }
        format.json { render json: @outlet.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def set_company
    @company = current_user.company
  end

  # Only allow a list of trusted parameters through.
  def outlet_params
    params.require(:outlet).permit(:name, :city, :country)
  end
end
