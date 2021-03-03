class Overture::NotesController < ApplicationController
  layout 'overture/application'
  include Overture::NotesHelper

  before_action :authenticate_user!
  before_action :set_company

  private

  def set_company
    @user = current_user
    @company = @user.company
  end

  def note_params
    params.require(:note).permit(:content, :notable_id, :notable_type, :approved, :remark)
  end
end
