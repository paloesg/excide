class NoteChannel < ApplicationCable::Channel
  def subscribed
    stream_from "note_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
