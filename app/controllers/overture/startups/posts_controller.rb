class Overture::Startups::PostsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_post, except: [:index, :create]

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Post
    @posts = policy_scope(Post)
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.author = @user
    @post.company = @company
    if @post.save
      redirect_to overture_startups_posts_path
    end
  end

  def show
    @topic = Topic.new
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to overture_startups_posts_path, notice: 'Announcement was successfully updated.' }
      else
        format.html { redirect_to overture_startups_posts_path, alert: 'Announcement was not updated.' }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @post.destroy
        format.html { redirect_to overture_startups_posts_path, notice: 'Announcement was successfully deleted.' }
      else
        format.html { redirect_to overture_startups_posts_path, alert: 'Announcement was not deleted.' }
      end
    end
  end

  private
  def set_company
    @user = current_user
    @company = current_user.company
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:id, :title, :content, :company_id, :author_id)
  end
end
