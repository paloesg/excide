class Overture::TopicsController < ApplicationController
  layout 'overture/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
    # Query topics by different col - Investor uses company_id, startup users by startup_id
    @topics = @company.investor? ? Topic.where(company: current_user.company) : Topic.where(startup_id: current_user.company.id)
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

  def set_company
    @user = current_user
    @company = current_user.company
  end

  def topic_params
    params.require(:topic).permit(:subject_name, :status, :question_category, :user, :company, :startup_id, notes_attributes: [:content, :user_id])
  end
end
