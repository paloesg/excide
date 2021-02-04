class Overture::CompaniesController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  def edit
    @contact = @company.contacts.find_by(searchable: true)
  end

  def update
    if @company.update(company_params)
      redirect_back(fallback_location: edit_overture_company_path(@company))
    else
      render :edit
    end
  end


  private
  def set_company
    @company = current_user.company
  end

  def company_params
    params.require(:company).permit(:id, :name, :uen, :contact_details, :financial_year_end, :gst_quarter, :agm_date, :ar_date, :eci_date, :form_cs_date, :project_start_date, :consultant_id, :associate_id, :shared_service_id, :designated_working_time, :xero_email, :connect_xero, :account_type, :stripe_subscription_plan_data, :trial_end_date, :slack_access_response, :before_deadline_reminder_days, :website_url, :report_url, :cap_table_url, :company_logo, :profile_logo, :banner_image, :company_bio, profile_attributes: [:id, :name, :url, :profile_logo, :company_information], contacts_attributes: [:id, :name, :phone, :email, :company_name, :created_by_id, :company_id, :contact_statuses_id, :investor_information, :investor_company_logo, :searchable], address_attributes: [:id, :line_1, :line_2, :postal_code, :city, :country, :state]
    )
  end
end
