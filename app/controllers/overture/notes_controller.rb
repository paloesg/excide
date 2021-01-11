class Overture::NotesController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :get_topic

  def index
    @notes = Note.includes(:notable).where(notable_id: @topic.id).order(created_at: :asc)
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    @note.user = current_user
    @note.notable = @topic
    # Save wfa reference to note if the note comes from workflow action
    if @note.save
    end
  end

  private
  def get_topic
    @topic = Topic.find(params[:topic_id])
  end

  def note_params
    params.require(:note).permit(:content, :notable_id, :notable_type)
  end
end
