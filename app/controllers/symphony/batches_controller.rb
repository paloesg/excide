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

  def assign_workflows_to_batch
    @batch = Batch.find_by(batch_identifier: params[:batch_identifier])
    @workflow = Workflow.find_by(identifier: params[:workflow_identifier])
    @workflow.batch_id = @batch.id
    respond_to do |format|
      if @workflow.save
        format.html { redirect_to @workflow.nil? ? symphony_documents_path : symphony_workflow_path(@workflow.template.slug, @workflow.identifier), notice: @batch.workflows.count.to_s + ' documents were successfully created.' }
        format.json { render :show, status: :created, location: @workflow}
      else
        format.html { render :new }
      end
    end
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