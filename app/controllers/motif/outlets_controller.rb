class Motif::OutletsController < ApplicationController


  private
  # Only allow a list of trusted parameters through.
  def outlet_params
    params.require(:outlet).permit(:name, :city, :country)
  end
end
