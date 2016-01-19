class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_projects, only: [:index, :show]

  def index
  end

  def show
    @project = @projects.find(params[:id])
    @business = @project.business
  end

  private

  def get_projects
    @user = current_user
    @projects = Project.active
  end
end