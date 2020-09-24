class Motif::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @folders = policy_scope(Folder).roots
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
