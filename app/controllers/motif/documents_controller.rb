class Motif::DocumentsController < ApplicationController
  before_action :set_company
  before_action :authenticate_user!

  def index
    @folders = policy_scope(Folder)
    @documents = policy_scope(Document)
  end

  def new
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end
end
