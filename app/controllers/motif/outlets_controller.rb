class Motif::OutletsController < ApplicationController
  layout 'motif/application'
  include Motif::OutletsHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles
  before_action :set_outlet, only: [:new, :edit, :update, :show]

  after_action :verify_authorized, except: [:index, :members]

  def index
    # params[:type] is for filtering direct owned and subfranchised
    @outlets = get_outlets_by_type(params[:type], @company)
    @outlet = Outlet.new
    build_franchisee
    @existing_users = @company.users
    # Query all franchisees where franchise_licensee is not blank (blank franchisees are created from direct owned outlet)
    @existing_franchisees = @company.franchisees.where.not(franchise_licensee: "")
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
    # Franchisor's direct outlet won't have franchisee present
    @outlet.franchisee = Franchisee.find_by(franchisee_company: @company).present? ? Franchisee.find_by(franchisee_company: @company) : nil
    # Link franchisor company to outlet
    @outlet.company = @company
    # Add role franchisee_owner to this new user
    @user.add_role(:franchisee_owner, @user.company)
    respond_to do |format|
      if @outlet.save
        # Clone template for outlet when saved. Check if user added unit franchisee or direct outlet by checking the franchise licensee value in the form.
        @outlet.clone_templates_for_outlet
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
    authorize @outlet
    build_addresses
    build_franchisee
    set_contact
  end

  def edit_franchisee_setting
    @outlet = Outlet.find(params[:outlet_id])
    set_contact
  end

  def update
    authorize @outlet
    # gsub(/\D/, "") keeps only the numbers which is the country code
    @outlet.contact = params[:country_code].gsub(/\D/, "") + params[:contact]
    if Phonelib.parse(@outlet.contact).valid?
      if @outlet.update(outlet_params)
        if outlet_params[:report_url].present?
          redirect_to motif_edit_report_path, notice: 'Successfully updated report link.'
        else
          current_user.has_role?(:franchisee_owner, @company) ? (redirect_to motif_outlet_edit_franchisee_setting_path(current_user.active_outlet), notice: "Successfully edited outlet information") : (redirect_to edit_motif_outlet_path(@outlet), notice: 'Successfully updated franchisee profile')
        end
      else
        redirect_to motif_root_path, alert: 'Updating franchisee profile has failed. Please contact admin for advise.'
      end
    else
      redirect_to edit_motif_outlet_path(@outlet)
      flash[:alert] = "Invalid Contact Number"
    end
  end

  def show
    authorize @outlet
  end

  def members
    @outlet = Outlet.find(params[:outlet_id])
    @users = @outlet.users
    # Find user that is in the company but not yet added to the outlet
    @existing_users = @company.users.includes(:outlets).where.not(outlets: { id: @outlet.id })
    # All the roles in that company
    @roles = @company_roles
    @user = User.new
  end

  def assigned_tasks
    @outlet = Outlet.find(params[:outlet_id])
    @workflows = @outlet.workflows
  end

  def email_new_outlet
    outlet_details = {
      full_name: params[:full_name],
      email: params[:email],
      unit_name: params[:unit_name],
      request_approved: params[:request_approved],
    }
    NotificationMailer.motif_new_outlet(current_user, outlet_details).deliver_later
    redirect_to motif_outlets_path, notice: "You are registering a new Outlet Entity. Please wait for further instructions which shall be communicated to you by email within 1 working day."
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
    params.require(:outlet).permit(:name, :city, :country, :contact, :address, :report_url, :header_image, franchisee_attributes: [:id, :parent_company_id, :license_type, :franchise_licensee, :registered_address, :commencement_date, :expiry_date, :renewal_period_freq_unit, :renewal_period_freq_value, :user_limit, :franchise_company_id], user_ids: [], address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state])
  end

  def build_franchisee
    if @outlet.franchisee.blank?
      @outlet.franchisee = @outlet.build_franchisee
    end
  end

  def build_addresses
    if @outlet.address.blank?
      @outlet.address = @outlet.build_address
    end
  end

  def set_company_roles
    @company_roles = Role.where(resource_id: @company.id, resource_type: "Company", name: ["franchisor", "franchisee_owner", "master_franchisee"])
  end

  # As country code and contact are displayed as tags in the edit page, user[contact_number] is not used in the edit and update and country code and contact field have to be manually set in controller.
  def set_contact
    @contact = Phonelib.parse(@outlet.contact)
    if @contact.valid?
      @country_code = @contact.country_code
      @contact = @outlet.contact.remove(@country_code)
      @country = Country.find_country_by_country_code(@country_code).name + " (+" + @country_code + ")"
    elsif @outlet&.address&.country.present?
      @country = @outlet.address.country + " (+" + Country.find_country_by_name(@outlet.address.country).country_code + ")"
    else
      @country = nil;
    end
  end
end
