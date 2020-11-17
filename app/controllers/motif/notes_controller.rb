class Motif::NotesController < ApplicationController
  layout 'motif/application'

  before_action :get_outlet, except: :communication_hub

  def communication_hub
    @outlets = current_user.company.outlets
  end

  def index
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    @note.user = current_user
    @note.notable = @outlet
    if @note.save
      ActionCable.server.broadcast("note_channel", content: @note.content)
    end
  end

  private
  def get_outlet
    @outlet = current_user.company.outlets.find(params[:outlet_id])
  end

  def note_params
    params.require(:note).permit(:content, :notable_id, :notable_type)
  end
end
