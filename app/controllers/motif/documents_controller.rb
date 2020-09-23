class Motif::DocumentsController < ApplicationController
  before_action :set_company
  before_action :authenticate_user!

  def index
    @folders = policy_scope(Folder).roots
    @documents = policy_scope(Document)
  end

  def new
  end

  def update_tags
    @document = @company.documents.find(params[:id])
    @tags = []
    params[:values].each{|key, tag| @tags << tag[:value]} unless params[:values].blank?
    @company.tag(@document, with: @tags, on: :tags)
    respond_to do |format|
      format.json { render json: @company.owned_tags.pluck(:name), status: :ok }
    end
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end
end
