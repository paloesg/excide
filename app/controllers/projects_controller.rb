class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_projects, only: [:index]

  def index
  end

  private

  def get_projects
    @user = current_user
    @projects = Project.active
  end
end