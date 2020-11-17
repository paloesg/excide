class Motif::NotesController < ApplicationController
  layout 'motif/application'

  def communication_hub
    @outlets = current_user.company.outlets
  end

  def index
    @outlet = current_user.company.outlets.find(params[:outlet_id])
  end
end
