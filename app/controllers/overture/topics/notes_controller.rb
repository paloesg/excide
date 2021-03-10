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
    @topic.transition(current_user.company)
    @note.notable = @topic
    if @note.save
      # Create activity history for QnA answers
      @note.create_activity key: 'note.qna_replies', owner: current_user, recipient: current_user.company,  params:{ topic_subject: @topic.subject_name, note_content: @note.content }
      # Only send email notification to all admins of the company if user with member role answer the question (Don't send email if admin answers)
      if current_user.has_role?(:member, current_user.company)
        current_user.company.users.with_role(:admin, current_user.company).each do |user|
          NotificationMailer.need_approval_notification(user, @topic, @note).deliver_later
        end
      end
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
