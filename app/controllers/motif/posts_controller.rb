class Motif::PostsController < ApplicationController
  layout 'motif/application'
  include Motif::PostsHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_post, except: [:index, :create]

  # after_action :verify_authorized
  # after_action :verify_policy_scoped, only: :index

  def index
    # authorize Post
    @posts = get_posts(@company).order('created_at DESC')
    # policy_scope(Post)
    @post = Post.new
    @authorized = (current_user.has_role?(:franchisor, current_user.company) or current_user.has_role?(:admin, current_user.company))
  end

  def create
    @post = Post.new(post_params)
    @post.author = @user
    @post.company = @company
    if @post.save
      redirect_to motif_posts_path, notice: "You have made an announcement."
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_back fallback_location: motif_posts_path, notice: 'Announcement was successfully updated.' }
      else
        format.html { redirect_back fallback_location: motif_posts_path, alert: 'Announcement was not updated.' }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @post.destroy
        format.html { redirect_to motif_posts_path, notice: 'Announcement was successfully deleted.' }
      else
        format.html { redirect_to motif_posts_path, alert: 'Announcement was not deleted.' }
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
