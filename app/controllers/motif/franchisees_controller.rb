class Motif::FranchiseesController < ApplicationController
  layout 'motif/application'
  
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_franchisee, only: [:show, :edit, :update]

  def index
    # Only query franchisees which doesnt have company name as franchise licensee
    @franchisees = @company.franchisees
  end

  def edit
    
  end

  def update
    if @franchisee.update(franchisee_params)
      redirect_to edit_motif_franchisee_path, notice: "Franchisee profile has been updated."
    else
      redirect_to motif_root_path, alert: 'Updating franchisee profile has failed. Please contact admin for advise.'
    end
  end

  def show
    # Check that franchisee's company has children and that it is a master franchisee (as this is the default role when creating one)
    @sub_franchisees = (@franchisee.company.children.present? and @franchisee.master_franchisee?) ? @franchisee.company.children.find_by(name: @franchisee.franchise_licensee).franchisees : []
  end

  def outlets
    @franchisee = @company.franchisees.find_by(id: params[:franchisee_id])
    @outlets = @franchisee.outlets
  end

  def users
    @franchisee = @company.franchisees.find_by(id: params[:franchisee_id])
    # Check if franchisee's company has children
    @users = @franchisee.company.children.present? ? @franchisee.company.children.find_by(name: @franchisee.franchise_licensee).users : @franchisee.outlets.map(&:users).flatten
  end

  def agreements
    @franchisee = @company.franchisees.find_by(id: params[:franchisee_id])
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
