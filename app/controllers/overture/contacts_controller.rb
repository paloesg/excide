class Overture::ContactsController < ApplicationController
  layout 'overture/application'
  include Overture::ContactsHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_contact, only: [:edit, :show, :update]
  before_action :get_contact_statuses, only: [:edit, :show, :index]
  after_action :verify_authorized

  def index
    authorize Contact
    # Only get investor's contact if they allow it to be public
    @contacts = Contact.where(searchable: true)
    @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(5)
  end

  def create
    if params[:contact_id].present?
      # This method is called when adding contacts or adding existing investor to fundraising board. It will clone the contact and set to the 1st contact status of the board.
      contact_to_be_duplicated = Contact.find(params[:contact_id])
      # Deep clone active storage attachment and action text rich text
      @contact = contact_to_be_duplicated.deep_clone include: [:rich_text_investor_information] do |original, kopy|
        if kopy.is_a?(Contact) && original.investor_company_logo.attached?
          original.investor_company_logo.open do |tempfile|
            kopy.investor_company_logo.attach({
              io: File.open(tempfile.path),
              filename: original.investor_company_logo.blob.filename,
              content_type: original.investor_company_logo.blob.content_type
            })
          end
        end
      end
      # Find the 1st contact status of the board (Shortlisted)
      contact_status = @company.contact_statuses.find_by(position: 1)
      @contact.contact_status = contact_status
      # Duplicate contact shouldn't be searchable
      @contact.searchable = false
      @contact.cloned_by = @company
    else
      # Add new investor's contact
      @contact = Contact.new(contact_params)
      @contact.created_by = current_user
    end
    # Redirect based on validation of contact
    if @contact.save
      redirect_to overture_contact_statuses_path, notice: "Investor contact added to fundraising board."
    else
      redirect_to overture_root_path, alert: "Error occurred when adding investor. Add a support ticket or try again in awhile."
    end
  end

  def edit

  end

  def update
    @contact_status = ContactStatus.find_by(id: params[:contact_status_id]) if params[:contact_status_id].present?
    # On the search investor page, the AJAX contact is the searchable contact, hence we need to get the cloned contact and update the cloned one instead of the searchable contact.
    @cloned_contact = get_cloned_contact(@contact, current_user) if params[:contact_type].present?
    respond_to do |format|
      if params[:contact_status_id].present?
        if params[:contact_type].present? ? @cloned_contact.update(contact_status: @contact_status) : @contact.update(contact_status: @contact_status)
          format.json { render json: { link_to: overture_contact_statuses_path, status: "ok" } }
        else
          format.html { redirect_to overture_root_path }
          format.json { render json: @contact.errors, status: :unprocessable_entity }
        end
      # This is to edit your cloned contact from the contact show page
      elsif @contact.update(contact_params)
        format.html { redirect_to overture_contact_path(@contact), notice: "Successfully updated information"}
      end
    end
  end

  def show
    authorize @contact
    @topic = Topic.new
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :phone, :email, :company_name, :created_by_id, :company_id, :contact_status_id, :cloned_by_id, :searchable, :investor_information, :investor_company_logo)
  end

  def get_contact_statuses
    @contact_statuses = ContactStatus.where(startup: @company)
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end
end
