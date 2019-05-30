class Symphony::TemplatesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
  	@templates = Template.all.where(company: @company)
  end

  def edit
  	@template = Template.find(params[:template_slug])
  	@section = Section.find(params[:section_id])
  end

  def update

  end

  private
  def set_company
  	@company = current_user.company
  end

  def template_params
  	params.require(:template).permit(:title, :company_id, :workflow_type)
  end
end