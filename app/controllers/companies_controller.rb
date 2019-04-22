class CompaniesController < ApplicationController
  layout "dashboard/application"

  before_action :authenticate_user!
  before_action :set_company, only: [:edit, :update]

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    @company.submit_details

    if @company.save
       render :edit
    end
  end

  def edit
    build_addresses
  end

  def update
    if @company.update(company_params)
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

  def company_params
    params.require(:company).permit(:id, :name, :uen, :contact_details, :financial_year_end, :gst_quarter, :agm_date, :ar_date, :eci_date, :form_cs_date, :project_start_date, :consultant_id, :associate_id, :shared_service_id, :designated_working_time, :xero_email, address_attributes: [:line_1, :line_2, :postal_code]
    )
  end

  def build_addresses
    if @company.address.blank?
      @company.address = @company.build_address
    end
  end
end
