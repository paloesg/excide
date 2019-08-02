class Symphony::BatchesController < ApplicationController
  layout 'dashboard/application'

  before_action :authenticate_user!
  before_action :set_company
  before_action :set_batch, only: [:show]
  before_action :set_s3_direct_post, only: [:show, :new]

  after_action :verify_authorized, except: [:index, :create]
  after_action :verify_policy_scoped, only: :index

  def index
    #Batch policy scope
    @batches = policy_scope(Batch).includes(:workflows, :template, :user)

    if current_user.has_role? :admin, @company
      @batches = @batches.order(created_at: :desc)
    else
      #Get current_user's id roles
      @current_user_roles = current_user.roles.pluck(:id)
      #Get batches If the current_user has the same role as a role in workflow_actions
      @batches = @batches.includes({workflows: [{template: [{sections: :tasks}]}]}).where(tasks: {role_id: @current_user_roles}).order(created_at: :desc)
    end
    @batches_paginate = Kaminari.paginate_array(@batches).page(params[:page]).per(10)
  end

  def new
    @batch = Batch.new
    authorize @batch
    @template = Template.find_by(slug: params[:batch_template_name])
  end

  def create
    @template = Template.find(params[:batch][:template_id])
    @generate_batch = GenerateBatch.new(current_user, @template, params[:batch]).run
    authorize @generate_batch.batch
    respond_to do |format|
      if @generate_batch.success?
        format.html { redirect_to symphony_batch_path(@template.slug, @generate_batch.batch.id), notice: 'Batch successfully created!' }
        format.json { render json: @generate_batch.batch, status: :ok }
      else
        format.html { redirect_to new_symphony_batch_path(@template.slug), alert: "There was an error archiving this workflow. Please contact your admin with details of this error: #{@generate_batch.message}." }
        format.json { render json: @generate_batch.message, status: :unprocessable_entity }
      end
    end
  end

  def show
    authorize @batch
    @current_user = current_user
    # @sections = @batch.template.sections
    # @templates = policy_scope(Template).assigned_templates(current_user)
    @roles = @current_user.roles.where(resource_id: @company.id, resource_type: "Company")
  end

  private

  def batch_params
    params.permit(:company_id, :template_id)
  end

  def set_batch
    @batch = policy_scope(Batch).find(params[:id])
  end

  def set_company
    @company = current_user.company
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end
end
