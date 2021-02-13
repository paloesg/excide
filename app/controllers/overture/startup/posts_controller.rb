class Overture::Startup::PostsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
  end

  private
  def set_company
    @user = current_user
    @company = current_user.company
  end

  def post_params
    params.require(:post).permit(:id, :title, :content, :company_id, :author_id)
  end
end
