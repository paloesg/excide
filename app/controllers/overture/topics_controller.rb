class Overture::TopicsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!

  def index
    @user = current_user
    @topics = Topic.where(user: current_user.id).order(created_at: :asc)
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)
    @topic.user = current_user
    @topic.company = current_user.company
    if @topic.save
      redirect_back fallback_location: overture_root_path, notice: 'Successfully open a question.'
    else
      render :new
    end 
  end

  private
  
  def topic_params
    params.require(:topic).permit(:subject_name, :status, :question_category, :user, :company, notes_attributes: [:content, :user_id])
  end
end
