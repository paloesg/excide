class Overture::ContactsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_contact, only: [:show, :update]
  after_action :verify_authorized

  def index
    # Only get investor's contact if they allow it to be public
    @contacts = Contact.where(searchable: true)
    @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(5)
  end

  def create
    if params[:contact_id].present?
      # This method is called when adding contacts or adding existing investor to fundraising board. It will duplicate the listed contact and set to the 1st contact status of the board.
      @contact_to_be_duplicated = Contact.find(params[:contact_id])
      @contact = @contact_to_be_duplicated.dup
      # Find the 1st contact status of the board (Shortlisted)
      @contact_status = @company.contact_statuses.find_by(position: 1)
      @contact.contact_status = @contact_status
      # Duplicate contact shouldn't be searchable
      @contact.searchable = false
      @contact.cloned_by = @company
      # Attach the investor company logo when duplicating contact
      @contact.investor_company_logo.attach(@contact_to_be_duplicated.investor_company_logo.blob) if @contact_to_be_duplicated.investor_company_logo.attached?
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

  def update
    # authorize @document
    @contact_status = ContactStatus.find_by(id: params[:contact_status_id])
    respond_to do |format|
      # check if update comes from drag and drop or from remarks. If folder_id is not present, then update remarks
      if @contact.update(contact_status: @contact_status)
        format.json { render json: { link_to: overture_contact_statuses_path, status: "ok" } }
      else
        format.html { redirect_to overture_root_path }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    authorize @contact
    @topic = Topic.new
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :phone, :email, :company_name, :created_by_id, :company_id, :contact_status_id, :cloned_by_id, :searchable)
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end
end
