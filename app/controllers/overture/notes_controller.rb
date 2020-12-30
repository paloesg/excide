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
    @note.workflow_action = WorkflowAction.find(params[:wfa_id]) if params[:wfa_id].present?
    if @note.save
      NoteChannel.broadcast_to(@note.notable, content: @note.content, user_name: @note.user.full_name, created_at: @note.created_at.strftime("%d %b %Y"), topic_id: @note.notable.id,  wf_id: @note.workflow_action&.workflow&.id, tem_title: @note.workflow_action&.workflow&.template&.title, task: @note.workflow_action&.task&.instructions)
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
