class Motif::CompaniesController < ApplicationController
  before_action :set_company
  # Index method is to list all the franchisees
  def index
    @outlets = Outlet.includes(:company).where(companies: { franchise_id: @company.id })
    @outlet = Outlet.new
    @franchisees = @company.franchisees
    @companies = Company.all
  end

  def edit
  end

  def edit_franchise
  end

  def update
    if @company.update(company_params)
      redirect_to edit_motif_company_path(@company), notice: 'Company was successfully updated.'
    else
      render :edit
    end
  end

  private
  def set_company
    @company = params[:franchisee_id].present? ? Company.find(params[:franchisee_id]) : current_user.company
  end

  def company_params
    params.require(:company).permit(:id, :name, :uen, :contact_details, :financial_year_end, :gst_quarter, :agm_date, :ar_date, :eci_date, :form_cs_date, :project_start_date, :consultant_id, :associate_id, :shared_service_id, :designated_working_time, :xero_email, :connect_xero, :account_type, :stripe_subscription_plan_data, :trial_end_date, :slack_access_response, :before_deadline_reminder_days, :website_url, :company_logo, :profile_logo, :banner_image, :company_bio, address_attributes: [:line_1, :line_2, :postal_code, :city, :country, :state]
    )
  end
end
