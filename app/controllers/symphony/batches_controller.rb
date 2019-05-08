class Symphony::BatchesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
    @batches = Batch.all
  end

  def new
    @batch = Batch.new
    @template = Template.find_by(slug: params[:batch_template_name])
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end

  def create
    @batch = Batch.new(batch_params)
    @batch.company = @company
    @template = Template.find(params[:batch][:template_id])
    @batch.template = @template
    @batch.batch_identifier = "hey-dropzone"
    @batch.save
  end

  def show
    @batch = Batch.find(params[:id])
  end

  private

  def batch_params
    params.permit(:company_id, :template_id, :batch_identifier)
  end

  def set_company
    @company = current_user.company
  end

  def template

  end
end