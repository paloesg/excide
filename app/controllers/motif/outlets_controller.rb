class Motif::OutletsController < ApplicationController
  layout 'motif/application'
  include Motif::OutletsHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_roles
  before_action :set_outlet, only: [:new, :edit, :update, :show]

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
    # Link franchisor company to outlet
    @outlet.company = @company
    # Add role franchisee_owner to this new user
    @user.add_role(:franchisee_owner, @user.company)
    respond_to do |format|
      if @outlet.save
        # Clone template for outlet when saved. Check if user added unit franchisee or direct outlet by checking the franchise licensee value in the form. Unit franchisee should clone template to it's company (could be MF) while direct outlet clone straight to parent company.
        @outlet.clone_templates_for_outlet(params[:outlet][:franchisee_attributes][:franchise_licensee].present? ? "unit_franchisee" : "direct_owned")
        if params[:outlet][:franchisee_attributes][:franchise_licensee].present?
          # By default, create retrospective workflows when creating unit franchisee
          template = Template.find_by(title: "Retrospective Documents")
          Workflow.create(user: current_user, company: @company, template: template, identifier: "#{params[:outlet][:franchisee_attributes][:franchise_licensee]} - Retrospective", franchisee: @outlet.franchisee)
        end
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
    build_franchisee
    set_contact
  end

  def edit_franchisee_setting
    @outlet = Outlet.find(params[:outlet_id])
    set_contact
  end

  def update
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

  end

  def members
    @outlet = @company.outlets.find(params[:outlet_id])
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
    NotificationMailer.motif_new_outlet(current_user).deliver_later
    redirect_to motif_outlets_path, notice: "Thank you for stating your interest in a new outlet. Kindly wait for further information as we contact you through email."
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
    params.require(:outlet).permit(:name, :city, :country, :contact, :address, :report_url, :header_image, franchisee_attributes: [:id, :company_id, :license_type, :franchise_licensee, :registered_address, :commencement_date, :expiry_date, :renewal_period_freq_unit, :renewal_period_freq_value], user_ids: [], address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state])
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
