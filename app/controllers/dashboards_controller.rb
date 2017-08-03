class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard, only: [:show]

  def show
    if @workflows.present?
      @tasks = []
      @workflows.each do |w|
        w.template.sections.each do |s|
          @tasks += s.tasks.joins(:company_actions).where(company_actions: {company: @company, completed: false})
        end
      end
    else
      @current_section = nil
      @tasks = nil
    end
  end

  private

  def set_dashboard
    @user = current_user

    if current_user.has_role? :admin
      @companies = Company.all
      @company = Company.find(params[:company_id])
    elsif params[:company_id].present?
      @company = @user.company
      redirect_to dashboard_path
    else
      @company = @user.company
    end

    @workflows = @company.workflows
    @documents = @company.documents.last(3).reverse
    @activities = PublicActivity::Activity.order("created_at desc").where(owner_id: current_user.id)
  end
end
