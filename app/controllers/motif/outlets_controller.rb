class Motif::OutletsController < ApplicationController
  layout 'motif/application'
  before_action :set_franchisee_and_outlet, except: [:create, :outlets_photos_upload]

  def create
    @outlet = Outlet.new(outlet_params)
    # Condition when franchisee is not in database, then we need to create a record
    if params[:franchisee_email].present?
      @franchisee = Franchisee.create(company: current_user.company)
      # Create user if not in motif
      @user = User.create_or_find_by(email: params[:franchisee_email], company: current_user.company, franchisee: @franchisee)
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
      redirect_to edit_motif_franchisee_outlet_path(@franchisee, @outlet), notice: 'Successfully updated franchisee profile'
    else
      redirect_to motif_root_path, alert: 'Updating franchisee profile has failed. Please contact admin for advise.'
    end
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

  private
  def set_franchisee_and_outlet
    @franchisee = Franchisee.find(params[:franchisee_id])
    @outlet = Outlet.find(params[:id])
  end
  # Only allow a list of trusted parameters through.
  def outlet_params
    params.require(:outlet).permit(:name, :city, :country, :contact, :address, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state], photos: [])
  end

  def build_addresses
    if @outlet.address.blank?
      @outlet.address = @outlet.build_address
    end
  end
end
