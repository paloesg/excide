class Motif::DocumentsController < ApplicationController
  before_action :set_company
  before_action :authenticate_user!

  def index
    @get_documents = Document.where(company: @company) #currently its only what the user uploaded
  end

  def new
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end
end
