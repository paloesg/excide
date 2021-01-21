class NoteChannel < ApplicationCable::Channel
  def subscribed
    stream_for outlet
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def outlet
    Outlet.find(params[:outlet_id])
  end
end
