class Symphony::HomeController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_workflow, only: [:show]

  def show
  end

  private

  def set_workflow
    @user = current_user
    @company = @user.company
    @templates = @company.templates
    @workflows_flatten = @templates.map(&:workflows).flatten
    @workflows = Kaminari.paginate_array(@workflows_flatten).page(params[:page]).per(10)
  end

end
