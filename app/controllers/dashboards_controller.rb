class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard

  def index
    @current_section = @workflows.first.template.sections.joins(tasks: :actions).where(actions: {completed: false}).to_ary.shift
    @tasks = @current_section.tasks
    @documents = @company.documents.last(3).reverse
  end

  private

  def set_dashboard
    @user = current_user
    @company = @user.company
    @workflows = @company.workflows
  end
end
