class Motif::OutletsController < ApplicationController
  layout 'motif/application'
  
  before_action :set_company
  before_action :set_company_roles
  before_action :set_outlet, only: [:new, :edit, :update, :show]
  # before_action :set_franchisee, except: [:create, :outlets_photos_upload, :add_new_onboarding, :index]

  def index
    @outlets = Outlet.includes(:company).where(company_id: @company)
  end

  def new

  end

  def create
    @outlet = Outlet.new(outlet_params)
    # Condition when franchisee is not in database, then we need to create a record
    if params[:franchisee_email].present?
      @franchisee = Franchisee.create(company: current_user.company)
      # Create user if not in motif
      @user = User.create(email: params[:franchisee_email], company: current_user.company, franchisee: @franchisee, outlet: @outlet)
      @user.add_role(:franchisee_owner, @user.company)
      @outlet.franchisee = @franchisee
    else
      # Else, just find franchisee from the ID returns by selection dropdown
      @outlet.franchisee = Franchisee.find_by(id: params[:franchisee_id])
    end
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

  def edit
    build_addresses
  end

  def update
    if @outlet.update(outlet_params)
      redirect_to edit_motif_outlet_path(@outlet), notice: 'Successfully updated franchisee profile'
    else
      redirect_to motif_root_path, alert: 'Updating franchisee profile has failed. Please contact admin for advise.'
    end
  end

  def show
    
  end

  def outlets_photos_upload
    @outlet = Outlet.find_by(id: params[:outlet_id])
    parsed_files = JSON.parse(params[:successful_files])
    parsed_files.each do |file|
      ActiveStorage::Attachment.create(name: 'photos', record_type: 'Outlet', record_id: @outlet.id, blob_id: ActiveStorage::Blob.find_by(key: file['response']['key']).id)
    end
    respond_to do |format|
      format.html { redirect_to edit_motif_franchisee_outlet_path(franchisee_id: @outlet.franchisee.id, id: @outlet.id), notice: "Photos successfully uploaded!" }
      format.json { render json: @files.to_json }
    end
  end

  def members
    @outlet = @company.outlets.find(params[:outlet_id])
    @users = @outlet.users
  end

  private
  def set_company
    @company = current_user.company
  end

  def set_outlet
    @outlet = Outlet.find(params[:id])
  end

  # def set_franchisee
  #   @franchisee = Franchisee.find(params[:franchisee_id])
  # end
  # Only allow a list of trusted parameters through.
  def outlet_params
    params.require(:outlet).permit(:name, :city, :country, :contact, :address, :commencement_date, :expiry_date, :renewal_period_freq_unit, :renewal_period_freq_value, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state], photos: [])
  end

  def build_addresses
    if @outlet.address.blank?
      @outlet.address = @outlet.build_address
    end
  end

  def set_company_roles
    @company_roles = Role.where(resource_id: @company.id, resource_type: "Company")
  end
end
