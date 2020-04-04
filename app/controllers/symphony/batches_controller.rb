class Symphony::BatchesController < ApplicationController
  layout 'metronic/application'

  before_action :authenticate_user!
  before_action :set_batch, only: [:show, :destroy]
  before_action :set_s3_direct_post, only: [:show, :new]

  after_action :verify_authorized, except: [:index, :create]
  after_action :verify_policy_scoped, only: :index

  def index
    # @batches = policy_scope(Batch).includes(:user, [workflows: :workflow_actions], :template)
    @batches = policy_scope(Batch).includes(:user, [workflows: :workflow_actions], :template).order(created_at: :desc)
    @completed = @batches.where(completed: true).count
    @total = @batches.count

    @batches = Kaminari.paginate_array(@batches).page(params[:page]).per(10)
  end

  def new
    @batch = Batch.new
    authorize @batch
    @template = Template.find_by(slug: params[:batch_template_name])
  end

  def create
    @template = Template.find_by(slug: params[:batch][:template_id])
    @generate_batch = GenerateBatch.new(current_user, @template).run
    authorize @generate_batch.batch
    respond_to do |format|
      if @generate_batch.success?
        flash[:notice] = "Batch created"
        format.json  { render :json => {:status => "ok", :batch_id => @generate_batch.batch.id} }
      else
        error_message = "There was an error creating this batch. Please contact your admin with details of this error: #{@generate_batch.message}"
        flash[:alert] = error_message
        output = { :status => "error", :message => error_message}
        format.json  { render :json => output }
      end
    end
  end

  def show
    authorize @batch
    @completed = @batch.workflows.where(completed: true).length
  end

  def destroy
    authorize @batch
    @batch.destroy
    redirect_to symphony_batches_index_path, notice: 'Batch was successfully deleted.'
  end

  private

  def batch_params
    params.permit(:company_id, :template_id)
  end

  def set_batch
    @batch = policy_scope(Batch).find(params[:id])
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end
end
