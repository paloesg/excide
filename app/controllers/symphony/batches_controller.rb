class Symphony::BatchesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company

  def index
    @batches_paginate = Kaminari.paginate_array(Batch.all.sort_by{ |a| a.created_at }.reverse!).page(params[:page]).per(10)
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
    @batch.save
  end

  def show
    @batch = Batch.find(params[:id])
    @s3_direct_post = S3_BUCKET.presigned_post(key: "#{@company.slug}/uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    @current_user = current_user
    @sections = @batch.template.sections
    @roles = @current_user.roles.where(resource_id: @company.id, resource_type: "Company")
  end

  private

  def batch_params
    params.permit(:company_id, :template_id)
  end

  def set_company
    @company = current_user.company
  end
end