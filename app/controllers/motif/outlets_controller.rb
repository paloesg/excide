class Motif::OutletsController < ApplicationController
  layout 'motif/application'

  def create
    if params[:franchisee_name].present?
      @franchisee = Franchisee.create(name: params[:franchisee_name], company: current_user.company)
    end
    @outlet = Outlet.new(outlet_params)
    @outlet.franchisee = @franchisee
    respond_to do |format|
      if @outlet.save
        format.html { redirect_to motif_franchisees_path, notice: 'Outlet was successfully created.' }
        format.json { render :show, status: :created, location: @outlet }
      else
        format.html { render :new }
        format.json { render json: @outlet.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Only allow a list of trusted parameters through.
  def outlet_params
    params.require(:outlet).permit(:name, :city, :country)
  end
end
