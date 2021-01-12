class Overture::NotesController < ApplicationController
  layout 'overture/application'
  include Overture::NotesHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :get_topic
  before_action :get_note, only: [:update]

  def index
    @notes = get_notes(@company, @topic)
    # @startup_notes = Note.includes(:topic).where(topic: { startup_id: @company.id })
    @note = Note.new
    # This will only be called if user is from a startup
    @users = @company.users if @user.company.startup?
  end

  def create
    @note = Note.new(note_params)
    @note.user = current_user
    # Change topic status to approve answer if company is a startup
    @topic.approve_answer if current_user.company.startup?
    @note.notable = @topic
    if @note.save and @topic.save
      redirect_to overture_topic_notes_path(topic_id: @topic.id), notice: "Answer has been posted. Please wait for answer to be approved."
    else
      render :new
    end
  end

  def update
    if params[:status] == "approve"
      @topic.approved
    else
      @topic.rejected
    end
    if @note.update(approved: params[:status] == "approve" ? true : false) and @topic.save
      redirect_to overture_topic_notes_path(@topic), notice: "Successfully updated topic."
    else
      render :edit
    end
  end

  private
  def get_topic
    @topic = Topic.find(params[:topic_id])
  end

  def get_note
    @note = Note.find(params[:id])
  end

  def set_company
    @user = current_user
    @company = @user.company
  end

  def note_params
    params.require(:note).permit(:content, :notable_id, :notable_type, :approved, :remark)
  end
end
