class Motif::ContactsController < ApplicationController
  layout 'motif/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_contact, only: [:show, :update, :destroy]
  # after_action :verify_authorized

  def index
    @contact = Contact.new
     # Filter contacts that are searchable true
    @public_key = Algolia.generate_secured_api_key(ENV['ALGOLIASEARCH_API_KEY_SEARCH'], {filters: 'searchable: true'})
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.created_by = current_user
    @contact.company = @company

    if params[:contact][:contact_status_id].present?
      @contact_status = policy_scope(ContactStatus).find(params[:contact][:contact_status_id])
      @contact.contact_status = @contact_status
      notice_message = "Contact added to lead management board."
    else
      notice_message = "Your brand will be added to the directory after 1-2 days! Thank you for your time!"
    end

    # Redirect based on validation of contact
    if @contact.save
      NotificationMailer.check_potential_franchise(@contact).deliver_later unless params[:contact][:contact_status_id].present?
      redirect_to params[:contact][:contact_status_id].present? ? motif_contact_statuses_path : motif_contacts_path, notice: notice_message
    else
      redirect_to motif_root_path, alert: "Error occurred. Add a support ticket or try again in awhile."
    end
  end

  def show

  end

  def register_interest
    @contact = Contact.find(params[:contact_id])
    @contact.register_interest_data << {
      title: params[:title] || nil,
      first_name: params[:first_name] || nil,
      last_name: params[:last_name] || nil,
      capital_available: params[:capital_available] || nil,
      mobile_country_code: params[:mobile_country_code] || nil,
      mobile_number: params[:mobile_number] || nil,
      email_address: params[:email_address] || nil,
      personal_email_address: params[:personal_email_address] || nil,
      company_name: params[:company_name] || nil,
      company_website: params[:company_website] || nil,
      my_designation: params[:my_designation] || nil,
      interests: params[:interests] || nil,
      others_reason: params[:others_reason] || "No other reasons of interest",
      areas_of_interest: params[:areas_of_interest] || nil,
      city: params[:city] || nil,
      previous_franchise: params[:previous_franchise] || nil,
      contact_name: @contact.name
    }
    respond_to do |format|
      if @contact.save
        # Send the email of the last registered interest (most recent one)
        NotificationMailer.registered_interest(@contact, @contact.register_interest_data.last).deliver_later
        format.html { redirect_to motif_contact_path(@contact), notice: "Interest registered. Please wait for us to contact you within the next few days." }
        format.json { render json: { link_to: motif_contact_statuses_path, status: "ok" } }
      else
        format.html { redirect_to motif_root_path, alert: "Error registering interest. Please try again." }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @contact_status = ContactStatus.find_by(id: params[:contact_status_id])
    respond_to do |format|
      # If cloned contact
      if @contact.update(contact_status: @contact_status)
        format.json { render json: { link_to: motif_contact_statuses_path, status: "ok" } }
      else
        format.html { redirect_to motif_root_path }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @contact.destroy
      respond_to do |format|
        format.html { redirect_to motif_contact_statuses_path }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Contact was successfully removed.'
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :phone, :email, :company_name, :industry, :year_founded, :country_of_origin, :markets_available, :franchise_fees, :average_investment, :royalty, :marketing_fees, :renewal_fees, :franchisor_tenure, :searchable, :description, :brand_logo, :register_interest_data, :created_by_id, :company_id, :contact_status_id)
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end
end
