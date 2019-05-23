class Symphony::BatchesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_batch, only: [:show]

  def index
    #get current_user's roles with all the word downcase for matching the string
    @current_user_roles = current_user.roles.names.map(&:downcase)
    if current_user.has_role? :admin, @company
      @batch = Batch.all.where(company: @company)
    else
      @batch = []
      #Loop all the batch and find same roles between the current_user's roles and the batch's workflows's roles. If the current_user has the same role as a role in workflow_actions, then save the batch into @batch.
      Batch.all.where(company: @company).each do |batch|
        #intersection operator & to get duplicate values of the role in both arrays
        @intersection = batch.get_relevant_roles & @current_user_roles
        @batch.push(batch) if @intersection.present?
      end
    end
    @batches_paginate = Kaminari.paginate_array(@batch.sort_by{ |a| a.created_at }.reverse!).page(params[:page]).per(10)

    #save all the progress into an array to set the progress bar in view page
    @batch_progress = []
    Batch.all.where(company: @company).sort_by{ |a| a.created_at }.reverse!.each do |batch|
      @batch_progress.push(batch.action_completed_progress)
    end

    # @batch_progress = Batch.last.action_completed_progress
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