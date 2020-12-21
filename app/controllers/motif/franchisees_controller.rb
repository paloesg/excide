class Motif::FranchiseesController < ApplicationController
  layout 'motif/application'
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_franchisee, only: :show

  def index
    # Only query franchisees which doesnt have company name as franchise licensee
    @franchisees = @company.franchisees
  end

  def show
    # To find the sub franchisee, get the children of the company's franchise, and find the company by matching the franchise_licensee with company name
    @sub_franchisees = @franchisee.company.children.find_by(name: @franchisee.franchise_licensee).franchisees
  end

  private

  def set_company
    @company = current_user.company
  end

  def set_franchisee
    @franchisee = Franchisee.find(params[:id])
  end

  def franchisee_params
    params.require(:franchisee).permit(:commencement_date, :expiry_date, :renewal_period_freq_unit, :renewal_period_freq_value, :franchise_licensee, :registered_address, :license_type, :max_outlet, :min_outlet, :storage_space)
  end
  
  def build_addresses
    if @franchisee.address.blank?
      @franchisee.address = @franchisee.build_address
    end
  end
end
