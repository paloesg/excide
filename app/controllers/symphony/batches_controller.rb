class Symphony::BatchesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company

  def new

  end

  def create
  	@batch = Batch.new(batch_params)
  	@batch.company = @company
  	respond_to do |format|
      if @batch.save
      	@batch.template = Template.find(params[:batch][:template_id])
      	format.html { redirect_to symphony_root_path), notice: 'Batch is created' }
      	format.json { render :show, status: :created, location: @batch}
      else
      	format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
  end

  private

  def batch_params
    params.require(:batch).permit(:company_id, :template_id)
  end

  def set_company
  	@company = current_user.company
  end

  def template

  end
end