class Motif::NotesController < ApplicationController
  layout 'motif/application'

  before_action :get_outlet, except: :communication_hub
  before_action :update_last_click_into_comm_hub, except: :create

  def communication_hub
    @outlets = current_user.company.outlets
  end

  def index
    @notes = Note.includes(:notable).where(notable_id: @outlet.id)
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    @note.user = current_user
    @note.notable = @outlet
    # Save wfa reference to note if the note comes from workflow action
    @note.workflow_action = WorkflowAction.find(params[:wfa_id]) if params[:wfa_id].present?
    if @note.save
      ActionCable.server.broadcast("note_channel", content: @note.content, user_name: @note.user.full_name, created_at: @note.created_at.strftime("%d %b %Y"), outlet_id: @note.notable.id,  wf_id: @note.workflow_action&.workflow&.id, tem_title: @note.workflow_action&.workflow&.template&.title, task: @note.workflow_action&.task&.instructions)
    end
  end

  private
  def get_outlet
    @outlet = current_user.company.outlets.find(params[:outlet_id])
  end

  def update_last_click_into_comm_hub
    current_user.update(last_click_comm_hub: DateTime.current)
  end

  def note_params
    params.require(:note).permit(:content, :notable_id, :notable_type)
  end
end
