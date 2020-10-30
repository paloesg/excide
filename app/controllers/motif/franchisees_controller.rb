class Motif::FranchiseesController < ApplicationController

  def index
    
  end

  def new
    
  end

  private
  def franchisee_params
    params.require(:franchisee).permit(:name, :website_url, :established_date, :telephone, :annual_turnover_rate, :currency, :address, :description, :contact_person_details)
  end
  
end
