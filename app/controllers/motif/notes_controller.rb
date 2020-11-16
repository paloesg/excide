class Motif::NotesController < ApplicationController
  layout 'motif/application'

  def index
    # get all notes (comment in the franchise)
    @notes = current_user.company.get_notes
  end
end
