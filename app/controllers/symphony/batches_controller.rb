class Symphony::BatchesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_batch, only: [:show]

  def index
    #get current_user's roles with all the word downcase for matching the string
    @current_user_roles = current_user.roles.role_names.map(&:downcase)
    @batch = []
    #Looping thru all the batch, the batch will get ALL the relevant roles from the workflows
    #@current_user_roles[index][item] is for matching the string. If batch_role is part of the display_name of user's role, then it will return true and push the batch record to @batch.
    Batch.all.each do |batch|
      if batch.get_relevant_role.each_with_index.any? {|batch_role, index| @current_user_roles[index][batch_role] }
        @batch.push(batch)
      end
    end
    @batches_paginate = Kaminari.paginate_array(@batch.sort_by{ |a| a.created_at }.reverse!).page(params[:page]).per(10)
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
    @s3_direct_post = S3_BUCKET.presigned_post(key: "#{@company.slug}/uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    @current_user = current_user
    @sections = @batch.template.sections
    @roles = @current_user.roles.where(resource_id: @company.id, resource_type: "Company")
  end

  private

  def batch_params
    params.permit(:company_id, :template_id)
  end

  def set_batch
    @batch = Batch.find(params[:id])
  end

  def set_company
    @company = current_user.company
  end
end