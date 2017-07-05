class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard

  def index
    if @workflows.present?
      @current_section = @workflows.first.template.sections.joins(tasks: :actions).where(actions: {completed: false}).to_ary.shift
      @tasks = @current_section.tasks
    else
      @current_section = nil
      @tasks = nil
    end
    @documents = @company.documents.last(3).reverse
  end

  private

  def set_dashboard
    @user = current_user
    @company = @user.company
    @workflows = @company.workflows
  end
end
