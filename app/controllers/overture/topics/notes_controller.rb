class Overture::Topics::NotesController < Overture::NotesController

  before_action :get_topic
  before_action :get_note, only: [:update, :destroy]

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
    if current_user.company.startup? and @topic.answered?
      # Change status to need_approval if startup user post again
      @topic.approve_another_answer
    elsif current_user.company.startup? and !@topic.answered?
      # Change topic status to approve answer if company is a startup and topic is not answered
      @topic.approve_answer
    end
    @note.notable = @topic
    if @note.save and @topic.save
      redirect_to overture_topic_notes_path(topic_id: @topic.id), notice: "Answer has been posted. Please wait for answer to be approved."
    else
      render :new
    end
  end

  def update
    # Change topic state
    if params[:status] == "approve"
      @topic.approved
    else
      @topic.rejected
    end
    remark = params[:note].present? ?  params[:note][:remark] : nil
    if @note.update(approved: params[:status] == "approve" ? true : false, remark: remark) and @topic.save
      redirect_to overture_topic_notes_path(@topic), notice: "Successfully updated topic."
    else
      render :edit
    end
  end

  def destroy
    @note.destroy
    redirect_to overture_topic_notes_path(@topic), notice: "Answer successfully deleted"
  end

  private
  def get_topic
    @topic = Topic.find(params[:topic_id])
  end

  def get_note
    @note = Note.find(params[:id])
  end
end
