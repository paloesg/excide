class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:index]

  def index
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to projects_path, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  private

  def set_project
    @user = current_user
    @business = @user.business
    @projects = @business.projects
  end

  def project_params
    params.require(:project).permit(:id, :title, :category, :description, :start_date, :end_date, :budget, :budget_type, :remarks, :status)
  end
end