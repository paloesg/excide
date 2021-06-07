class Overture::ContactStatusesController < ContactStatusesController
  layout 'overture/application'

  before_action :set_company
  before_action :set_contact_status, only: [:update, :destroy]
  after_action :verify_authorized

  def index
    authorize ContactStatus
    @contact_statuses = @company.contact_statuses
    @contact_status = ContactStatus.new
    @contact = Contact.new
    @existing_contacts = Contact.includes(:company).where(companies: {company_type: "investor"}, searchable: true)
  end

  def create
    @contact_status = ContactStatus.create(contact_status_params)
    @contact_status.startup = @company
    # Set new contact status's position by taking the last position, plus 1
    @contact_status.position = @company.contact_statuses.last.position + 1
    if @contact_status.save
      redirect_to overture_contact_statuses_path, notice: "Status created!"
    else
      redirect_to overture_contact_statuses_path, alert: "Failed to create contact status!"
    end
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
    if @contact_status.destroy
      respond_to do |format|
        format.html { redirect_to overture_contact_statuses_path }
        format.js   { render js: 'Turbolinks.visit(location.toString());' }
      end
      flash[:notice] = 'Column was successfully deleted.'
    end
  end

  private

  def set_contact_status
    @contact_status = ContactStatus.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end
end
