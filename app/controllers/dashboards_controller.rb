class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard, only: [:show]

  def index
    @user = current_user
    @company = Company.first
    @workflows = @company.workflows
    @documents = @company.documents.last(3).reverse

    render :show
  end

  def show
    if @workflows.present?
      @current_section = @workflows.first.template.sections.joins(tasks: :actions).where(actions: {completed: false}).to_ary.shift
      @tasks = @current_section.tasks
    else
      @current_section = nil
      @tasks = nil
    end
  end

  private

  def set_dashboard
    @user = current_user
    @company = @user.company
    @workflows = @company.workflows
    @documents = @company.documents.last(3).reverse
  end
end
