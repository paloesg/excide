class Symphony::BatchesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
    @batches = Batch.all
  end

  def new

  end

  def create
    @batch = Batch.new(batch_params)
    @batch.company = @company
    @template = Template.find(params[:batch][:template_id])
    @batch.template = @template
    @batch.batch_identifier = params[:batch][:batch_identifier]
    @batch.save
  end

  def show
    @batch = Batch.find(params[:id])
  end

  private

  def batch_params
    params.require(:batch).permit(:company_id, :template_id, :batch_identifier)
  end

  def set_company
    @company = current_user.company
  end

  def template

  end
end