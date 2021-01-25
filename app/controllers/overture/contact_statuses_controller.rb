class Overture::ContactStatusesController < ContactStatusesController
  layout 'overture/application'

  before_action :set_company

  def index
    @contact_statuses = @company.contact_statuses.order('position ASC')
    @contact = Contact.new
    @existing_contacts = Contact.includes(:company).where(companies: {company_type: "investor"}, searchable: true)
  end

  private

  def set_company
    @company = current_user.company
  end
end
