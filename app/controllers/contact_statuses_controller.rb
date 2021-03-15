class ContactStatusesController < ApplicationController
  # This controller is shared for all kanban boards in paloe's products

  private
  def contact_status_params
    params.require(:contact_status).permit(:name, :position, :startup_id, :colour)
  end
end
