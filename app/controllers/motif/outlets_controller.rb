class Motif::OutletsController < ApplicationController
  layout 'motif/application'
  
  before_action :set_company
  before_action :set_company_roles
  before_action :set_outlet, only: [:new, :edit, :update, :show]

  def index
    @outlets = Outlet.includes(:company).where(company_id: @company)
    @outlet = Outlet.new
  end

  def new

  end

  def create
    @outlet = Outlet.new(outlet_params)
    # Condition when franchisee is not in database, then we need to create a record
    if params[:user_email].present?
      # Create user if user's email is not in motif
      @user = User.find_or_create_by(email: params[:user_email], company: @company)
      # Add role franchisee_owner to this new user
      @user.add_role(:franchisee_owner, @user.company)
      # Link outlet to company
      @outlet.company = @company
    end
    respond_to do |format|
      if @outlet.save
        # Save outlet to user
        @user.outlet = @outlet
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

  def update
    if @outlet.update(outlet_params)
      if outlet_params[:report_url].present?
        redirect_to motif_edit_report_path, notice: 'Successfully updated report link.'
      else
        redirect_to edit_motif_outlet_path(@outlet), notice: 'Successfully updated franchisee profile'
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

<<<<<<< HEAD
  def outlets_documents_upload
    @files = []
    @outlet = Outlet.find_by(id: params[:outlet_id])
    parsed_files = JSON.parse(params[:successful_files])
    parsed_files.each do |file|
      @generate_document = GenerateDocument.new(@user, @company, nil, nil, nil, params[:document_type], nil).run_without_associations
      document = @generate_document.document
      authorize document
      # attach and convert method with the response key to create blob
      document.attach_and_convert_document(file['response']['key'])
      @files.append document
    end
    respond_to do |format|
      format.html { edirect_to edit_motif_franchisee_outlet_path(franchisee_id: @outlet.franchisee.id, id: @outlet.id), notice: "Documents successfully uploaded!" }
      format.json { render json: @files.to_json }
    end
=======
  def members
    @outlet = @company.outlets.find(params[:outlet_id])
    @users = @outlet.users
    @existing_users = @company.users.includes(:outlet).where.not(outlet_id: @outlet.id)
    @user = User.new
  end

  def assigned_tasks
    @outlet = @company.outlets.find(params[:outlet_id])
    @workflows = @outlet.workflows
>>>>>>> develop
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
    params.require(:outlet).permit(:name, :city, :country, :contact, :address, :commencement_date, :expiry_date, :renewal_period_freq_unit, :renewal_period_freq_value, :report_url, :header_image, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state])
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
