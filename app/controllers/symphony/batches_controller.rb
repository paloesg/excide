class Symphony::BatchesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_batch, only: [:show]
  before_action :set_s3_direct_post, only: [:show, :new]

  after_action :verify_authorized, except: [:index, :search]
  after_action :verify_policy_scoped, only: :index

  def index
    #get current_user's id roles
    @current_user_roles = current_user.roles.pluck(:id)

    if current_user.has_role? :admin, @company
      @batches = Batch.where(company: @company).order(created_at: :desc)
      #save all the progress into an array to set the progress bar in view page
    else
      #Get batches If the current_user has the same role as a role in workflow_actions
      @batches =  Batch.includes(:workflows => [:template => [:sections => :tasks]]).where(:tasks => {:role_id => @current_user_roles}).order(created_at: :desc)
    end
    #batch policy scope
    policy_batches = policy_scope(@batches)
    @batches_paginate = Kaminari.paginate_array(policy_batches).page(params[:page]).per(10)
  end

  def new
    @batch = Batch.new
    authorize @batch
    @template = Template.find_by(slug: params[:batch_template_name])
  end

  def create
    @batch = Batch.new(batch_params)
    authorize @batch
    @batch.company = @company
    @template = Template.find(params[:batch][:template_id])
    @batch.template = @template
    @batch.user = current_user
    @batch.save
    respond_to do |format|
      format.json  { render :json => {:batch_id => @batch.id} }
    end
  end

  def show
    authorize @batch
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

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end
end