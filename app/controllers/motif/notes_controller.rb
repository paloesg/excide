class Motif::NotesController < ApplicationController
  layout 'motif/application'

  def index
    @outlets = current_user.company.outlets
  end
end
