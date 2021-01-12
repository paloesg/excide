class Overture::TopicsController < ApplicationController
  layout 'overture/application'
  include Overture::TopicsHelper

  before_action :authenticate_user!
  before_action :set_company

  def index
    # Question category comes from the sidebar
    @topics = get_topics(@company, params[:question_category])
    @topic = Topic.new
    @topic.notes.new
  end

  def create
    @topic = Topic.new(topic_params)
    @topic.notes.first.user_id = current_user.id
    @topic.user = current_user
    @topic.company = current_user.company
    if @topic.save
      redirect_back fallback_location: overture_root_path, notice: 'Successfully open a question.'
    else
      render :new
    end
  end

  private

  def set_company
    @user = current_user
    @company = current_user.company
  end

  def topic_params
    params.require(:topic).permit(:subject_name, :status, :question_category, :user, :company, :startup_id, notes_attributes: [:content, :user_id, :approved])
  end
end
