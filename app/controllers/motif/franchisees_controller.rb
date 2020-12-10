class Motif::FranchiseesController < ApplicationController
  layout 'motif/application'
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_franchisee, except: :index

  def index
    @franchisees = Franchisee.includes(:company).where(company_id: @company)
    @outlets = Outlet.includes(:franchisee).where(franchisees: { company_id: @company })
    @outlet = Outlet.new
  end

  def edit
    build_addresses
  end

  def update
    @franchisee.contact_person_details = {
      position: params[:position],
      capital_available_for_investment: params[:capital],
      your_franchise_experience: params[:your_franchise_experience],
      other_experience: params[:other_experience],
    }

    if @franchisee.update(franchisee_params)
      redirect_to edit_motif_franchisee_path(@franchisee), notice: 'Successfully updated franchisee profile'
    else
      redirect_to motif_root_path, alert: 'Updating franchisee profile has failed. Please contact admin for advise.'
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_franchisee
    @franchisee = Franchisee.find(params[:id])
  end

  def franchisee_params
    params.require(:franchisee).permit(:commencement_date, :expiry_date, :renewal_period_freq_unit, :renewal_period_freq_value, :franchise_licensee, :registered_address)
  end
  
  def build_addresses
    if @franchisee.address.blank?
      @franchisee.address = @franchisee.build_address
    end
  end
end
