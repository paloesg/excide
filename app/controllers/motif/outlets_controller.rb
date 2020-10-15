class Motif::OutletsController < ApplicationController
  def index
    @outlets = Outlet.where(company: @company)
    @outlet = Outlet.new
    @companies = Company.all
  end

  def create
    @outlet = Outlet.new(outlet_params)
    @outlet.company = Company.find_by(id: params[:company_id])
    respond_to do |format|
      if @outlet.save
        format.html { redirect_to motif_outlets_path, notice: 'Outlet was successfully created.' }
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
