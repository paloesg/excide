class Motif::CompaniesController < ApplicationController
  layout 'motif/application'
  
  before_action :set_company
  def edit
    build_addresses
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
    @company = current_user.company
  end

  def company_params
    params.require(:company).permit(:id, :name, :uen, :contact_details, :financial_year_end, :gst_quarter, :agm_date, :ar_date, :eci_date, :form_cs_date, :project_start_date, :consultant_id, :associate_id, :shared_service_id, :designated_working_time, :xero_email, :connect_xero, :account_type, :stripe_subscription_plan_data, :trial_end_date, :slack_access_response, :before_deadline_reminder_days, :website_url, :report_url, :company_logo, :profile_logo, :banner_image, :company_bio, address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]
    )
  end

  def build_addresses
    if @company.address.blank?
      @company.address = @company.build_address
    end
  end
end
