class Motif::ContactsController < ApplicationController
  layout 'motif/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_contact, only: [:update, :destroy]
  # after_action :verify_authorized

  def index
    @contacts = Contact.all
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
      @contact.searchable = true
      notice_message = "Added brand to directory!"
    end

    # Redirect based on validation of contact
    if @contact.save
      redirect_to params[:contact][:contact_status_id].present? ? motif_contact_statuses_path : motif_contacts_path, notice: notice_message
    else
      redirect_to motif_root_path, alert: "Error occurred. Add a support ticket or try again in awhile."
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
    params.require(:contact).permit(:name, :industry, :year_founded, :country_of_origin, :markets_available, :franchise_fees, :average_investment, :royalty, :marketing_fees, :renewal_fees, :franchisor_tenure, :searchable, :description, :brand_logo, :created_by_id, :company_id, :contact_status_id)
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end
end
