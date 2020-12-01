class Motif::OutletsController < ApplicationController
  layout 'motif/application'
  
  before_action :set_company
  before_action :set_company_roles
  before_action :set_outlet, only: [:new, :edit, :update, :show]

  def index
    @outlets = Outlet.includes(:company).where(company_id: @company)
    @outlet = Outlet.new
    @existing_users = @company.users
  end

  def new

  end

  def create
    @outlet = Outlet.new(outlet_params)
    # Condition when franchisee is not in database, then we need to create a record
    if params[:user_email].present?
      # Create user if user's email is not in motif
      @user = User.find_or_create_by(email: params[:user_email], company: @company)
    else
      @user = User.find(params[:user_id])
    end
    # Add role franchisee_owner to this new user
    @user.add_role(:franchisee_owner, @user.company)
    # Link outlet to company
    @outlet.company = @company
    respond_to do |format|
      if @outlet.save
        # Save outlet to user
        @user.outlets << @outlet
        # Set active outlet to the new saved outlet
        @user.active_outlet = @outlet
        @user.save
        format.html { redirect_to motif_outlets_path, notice: 'Outlet was successfully created.' }
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

  def edit_franchisee_setting
    @outlet = Outlet.find(params[:outlet_id])
  end

  def update
    if @outlet.update(outlet_params)
      if outlet_params[:report_url].present?
        redirect_to motif_edit_report_path, notice: 'Successfully updated report link.'
      else
        current_user.has_role?(:franchisee_owner, @company) ? (redirect_to motif_outlet_edit_franchisee_setting_path(current_user.active_outlet), notice: "Successfully edited outlet information") : (redirect_to edit_motif_outlet_path(@outlet), notice: 'Successfully updated franchisee profile')
      end
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
    # Find user that is in the company but not yet added to the outlet
    @existing_users = @company.users.includes(:outlets).where.not(outlets: { id: @outlet.id })
    # All the roles in that company
    @roles = Role.where(resource_id: @company.id, resource_type: "Company")
    @user = User.new
  end

  def assigned_tasks
    @outlet = @company.outlets.find(params[:outlet_id])
    @workflows = @outlet.workflows
  end

  private
  def set_company
    @company = current_user.company
  end

  def set_outlet
    @outlet = Outlet.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def outlet_params
    params.require(:outlet).permit(:name, :city, :country, :contact, :address, :commencement_date, :expiry_date, :renewal_period_freq_unit, :renewal_period_freq_value, :report_url, :header_image, user_ids: [], address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state])
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
