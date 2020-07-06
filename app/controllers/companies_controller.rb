class CompaniesController < ApplicationController
  layout 'metronic/application'

  before_action :authenticate_user!
  before_action :set_company, only: [:show, :edit, :update]

  after_action :verify_authorized

  def show
    authorize @company
    @address = @company&.address
    @users = User.where(company: @company).order(:id).includes(:roles)
  end

  def new
    @company = Company.new
    authorize @company
  end

  def create
    @company = Company.new(company_params)
    authorize @company

    if @company.save
      set_company_roles
      current_user.update(company: @company)
      redirect_to symphony_root_path
    end
  end

  def edit
    authorize @company
    build_addresses
  end

  def update
    authorize @company
    # Store old roles
    @old_roles = { consultant: @company.consultant, associate: @company.associate, shared_service: @company.shared_service }

    if @company.update(company_params)
      # Remove all company roles except admin before updating company in case company roles have changed.
      remove_company_roles
      set_company_roles
      redirect_to edit_company_path, notice: 'Company was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end

  def set_company_roles
    # Set company admin role only if old roles is not defined i.e. creating new company
    current_user.add_role(:admin, @company) unless defined?(@old_roles)

    @company.consultant.add_role(:consultant, @company) if @company.consultant.present?
    @company.associate.add_role(:associate, @company) if @company.associate.present?
    @company.shared_service.add_role(:shared_service, @company) if @company.shared_service.present?
  end

  def remove_company_roles
    @old_roles[:consultant]&.remove_role(:consultant, @company)
    @old_roles[:associate]&.remove_role(:associate, @company)
    @old_roles[:shared_service]&.remove_role(:shared_service, @company)
  end

  def company_params
    params.require(:company).permit(:id, :name, :uen, :contact_details, :financial_year_end, :gst_quarter, :agm_date, :ar_date, :eci_date, :form_cs_date, :project_start_date, :consultant_id, :associate_id, :shared_service_id, :designated_working_time, :xero_email, :connect_xero, :account_type, :stripe_subscription_plan_data, :trial_end_date, :slack_access_response, :prior_days, address_attributes: [:line_1, :line_2, :postal_code, :city, :country, :state]
    )
  end

  def build_addresses
    if @company.address.blank?
      @company.address = @company.build_address
    end
  end
end
