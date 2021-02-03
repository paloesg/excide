class NoteChannel < ApplicationCable::Channel
  def subscribed
    if params[:outlet_id].present?
      outlet = Outlet.find(params[:outlet_id])
      stream_for outlet
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
