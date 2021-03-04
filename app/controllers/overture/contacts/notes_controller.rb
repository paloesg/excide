class Overture::Contacts::NotesController < Overture::NotesController
  before_action :set_contact
  before_action :set_note, only: [:edit, :update]
  before_action :set_contact_statuses, only: [:index, :new, :edit]

  def index
    @notes = @contact.notes
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    @note.user = current_user
    @note.notable = @contact
    if @note.save
      redirect_to overture_contact_notes_path(contact_id: @contact.id), notice: "Note has been saved successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to overture_contact_notes_path(contact_id: @contact.id), notice: "Note has been updated successfully."
    else
      render :edit
    end
  end

  private
  def set_contact_statuses
    @contact_statuses = ContactStatus.where(startup: @company)
  end

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end

  def set_note
    @note = @contact.notes.find(params[:id])
  end
end
