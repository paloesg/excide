class Overture::Contacts::NotesController < Overture::NotesController
  before_action :set_contact

  def index

  end

  private
  def set_contact
    @contact = Contact.find(params[:contact_id])
  end
end
