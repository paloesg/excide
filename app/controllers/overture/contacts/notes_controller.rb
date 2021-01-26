class Overture::Contacts::NotesController < Overture::NotesController
  before_action :set_contact

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

  private
  def set_contact
    @contact = Contact.find(params[:contact_id])
  end
end
