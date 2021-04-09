class Motif::ContactStatusesController < ApplicationController
  layout 'motif/application'

  before_action :authenticate_user!

  def index
    @contact_statuses = policy_scope(ContactStatus).order('position ASC')
    # @existing_contacts = Contact.includes(:company).where(companies: {company_type: "investor"}, searchable: true)
  end

  private
  def contact_status_params
    params.require(:contact_status).permit(:name, :position, :company_id)
  end
end
