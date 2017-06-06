class Company::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_projects, only: [:index, :create, :show, :edit, :update]

  def index
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.company_id = @company.id
    @project.status = "in_review"

    if @project.save
      redirect_to company_projects_path, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def show
    @project = @projects.find(params[:id])
    @proposals = @project.proposals
  end

  def edit
    @project = @projects.find(params[:id])
  end

  def update
    @project = @projects.find(params[:id])

    if @project.update(project_params)
      redirect_to company_projects_path, notice: 'Your project was successfully updated.'
    else
      render :edit
    end
  end

  private

  def get_projects
    @user = current_user
    @company = @user.company
    @projects = @company.projects
  end

  def project_params
    params.require(:project).permit(:id, :title, :project_category_id, :description, :start_date, :end_date, :budget, :budget_type, :remarks, :status, :company_id, :criteria, :grant)
  end
end