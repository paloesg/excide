class Overture::NotesController < ApplicationController
  layout 'overture/application'
  include Overture::NotesHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :get_topic

  def index
    @notes = get_notes(@company, @topic)
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    @note.user = current_user
    @note.notable = @topic
    if @note.save
      redirect_to overture_topic_notes_path(topic_id: @topic.id), notice: "Answer has been posted. Please wait for answer to be approved."
    else
      render :new
    end
  end

  private
  def get_topic
    @topic = Topic.find(params[:topic_id])
  end

  def set_company
    @user = current_user
    @company = @user.company
  end

  def note_params
    params.require(:note).permit(:content, :notable_id, :notable_type, :approved)
  end
end
