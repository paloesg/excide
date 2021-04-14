class Motif::FranchiseesController < ApplicationController
  layout 'motif/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_franchisee, only: [:show, :edit, :update]
  before_action :set_franchisee_by_id, only: [:outlets, :users, :agreements, :upload_agreements]

  def index
    # Query all franchisees where franchise_licensee is not blank (blank franchisees are created from direct owned outlet)
    @franchisees = @company.franchisees.where.not(franchise_licensee: "")
  end

  def edit
  end

  def update
    if @franchisee.update(franchisee_params)
      redirect_to edit_motif_franchisee_path, notice: "Franchisee profile has been updated."
    else
      render :edit
    end
  end

  def show
    # Check franchisee license type
    @sub_franchisees = @franchisee.check_license_type_master_or_area_or_multi_unit? ? @franchisee.franchisee_company.franchisees.where.not(franchise_licensee: "") : []
  end

  def outlets
    @outlets = @franchisee.check_license_type_master_or_area_or_multi_unit? ? @franchisee.franchisee_company.outlets : []
  end

  def users
    @users = @franchisee.check_license_type_master_or_area_or_multi_unit? ? @franchisee.franchisee_company.users : @franchisee.outlets.map(&:users).flatten
  end

  def email_new_franchisee
    franchisee_details = {
      full_name: params[:full_name],
      email: params[:email],
      unit_name: params[:unit_name],
      license_type: params[:license_type]
    }
    NotificationMailer.motif_new_franchisee(current_user, franchisee_details).deliver_later
    redirect_to motif_franchisees_path, notice: "You are registering a new Franchisee Entity. Please wait for further instructions which shall be communicated to you by email within 1 working day."
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end

  def set_franchisee
    @franchisee = Franchisee.find(params[:id])
  end

  def set_franchisee_by_id
    # Get franchisee by franchisee ID
    @franchisee = @company.franchisees.find_by(id: params[:franchisee_id])
  end

  def franchisee_params
    params.require(:franchisee).permit(:commencement_date, :expiry_date, :renewal_period_freq_unit, :renewal_period_freq_value, :franchise_licensee, :registered_address, :license_type, :max_outlet, :min_outlet, :report_url)
  end

  def build_addresses
    if @franchisee.address.blank?
      @franchisee.address = @franchisee.build_address
    end
  end
end
