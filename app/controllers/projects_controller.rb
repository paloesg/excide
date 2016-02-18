class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_projects, only: [:index, :show]
  before_action :set_s3_direct_post, only: [:show]

  def index
  end

  def show
    @project = @projects.find(params[:id])
    @business = @project.business

    @proposal = Proposal.new(project_id: @project.id)
  end

  private

  def get_projects
    @user = current_user
    @projects = Project.active
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end
end