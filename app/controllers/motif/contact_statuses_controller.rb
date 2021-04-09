class Motif::ContactStatusesController < ApplicationController
  layout 'motif/application'

  before_action :authenticate_user!

  private
  def contact_status_params
    params.require(:contact_status).permit(:name, :position, :company_id)
  end
end
