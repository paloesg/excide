class Overture::ContactStatusesController < ContactStatusesController
  layout 'overture/application'

  before_action :set_company

  def index
    @contact_statuses = @company.contact_statuses.order('position ASC')
  end

  private

  def set_company
    @company = current_user.company
  end
end
