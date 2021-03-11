class Overture::Startups::PostsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
    @posts = policy_scope(Post)
    @post = Post.new
  end

  private

  def post_params
    params.require(:post).permit(:id, :title, :content, :company_id, :author_id)
  end
end
