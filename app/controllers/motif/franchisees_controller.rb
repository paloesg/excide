class Motif::FranchiseesController < ApplicationController
  layout 'motif/application'
  
  before_action :authenticate_user!
  before_action :set_company

  def index
    @franchisees = @company.franchisees
  end

  private

  def set_company
    @company = current_user.company
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
