class Overture::TopicsController < ApplicationController
  layout 'overture/application'
  include Overture::TopicsHelper

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_topic, only: [:update]

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

  def update
    # For investor to close question
    if params[:status].present?
      @topic.close_question
      if @topic.save
        redirect_to overture_topics_path, notice: "Successfully closed question."
      else
        redirect_to overture_root_path, alert: "Error in closing question."
      end
    # For startup admin to assign user to question
    elsif @topic.update(topic_params)
      assigned_user = @company.users.find_by(id: @topic.assigned_user_id)
      NotificationMailer.assign_to_question_notification(assigned_user, @topic).deliver_later
      redirect_to overture_topic_notes_path(@topic), notice: "Successfully assigned user. Please wait for user to answer the question."
    else
      render :edit
    end
  end

  private

  def set_company
    @user = current_user
    @company = current_user.company
  end

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:subject_name, :status, :question_category, :user, :company, :startup_id, :assigned_user_id, notes_attributes: [:content, :user_id, :approved])
  end
end
