class Symphony::BatchesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!

  def new

  end

  def create

  end

  private

  def batch_params
    params.require(:batch).permit(:company_id, :template_id)
  end
end