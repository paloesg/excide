class Motif::FranchiseesController < ApplicationController
  before_action :set_company, except: :index
  before_action :set_franchisee, except: :index

  def index
    @franchisees = Franchisee.all
    @outlets = Outlet.all
    @outlet = Outlet.new
  end

  def edit
    
  end

  def update
    
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_franchisee
    @franchisee = Franchisee.find(params[:id])
  end

  def franchisee_params
    params.require(:franchisee).permit(:name, :website_url, :established_date, :telephone, :annual_turnover_rate, :currency, :address, :description, :contact_person_details)
  end
  
end
