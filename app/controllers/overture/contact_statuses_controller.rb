class Overture::ContactStatusesController < ContactStatusesController
  layout 'overture/application'

  before_action :set_company
  before_action :set_contact_status, only: [:update, :destroy]
  after_action :verify_authorized

  def index
    authorize ContactStatus
    @contact_statuses = @company.contact_statuses.order('position ASC')
    @contact = Contact.new
    @existing_contacts = Contact.includes(:company).where(companies: {company_type: "investor"}, searchable: true)
  end

  def update
    respond_to do |format|
      if @contact_status.update(contact_status_params)
        format.json { render json: @contact_status, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @contact_status.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy

  end

  private

  def set_contact_status
    @contact_status = ContactStatus.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end
end
