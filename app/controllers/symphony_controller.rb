class SymphonyController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_workflow, only: [:show]

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

  def set_workflow
    @user = current_user
    @company = @user.company
    @templates = @company.templates
    @workflows = @company.workflows
  end

end
