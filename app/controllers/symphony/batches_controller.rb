class Symphony::BatchesController < ApplicationController
  layout 'metronic/application'

  before_action :authenticate_user!
  before_action :set_batch, only: [:show, :destroy]
  before_action :set_s3_direct_post, only: [:show, :new]

  after_action :verify_authorized, except: [:index, :create]
  after_action :verify_policy_scoped, only: :index

  def index
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
    @template = Template.find_by(slug: params[:batch][:template_slug])
    files = JSON.parse(params[:successful_results])['successful']
    document_type = params[:document_type]
    # Add attributes of batches
    @batch = Batch.new(user: current_user, template: @template, company: current_user.company)
    # authorize @generate_batch.batch
    respond_to do |format|
      if @batch.save!
        # Run background job to generate documents
        BatchUploadsJob.perform_later(current_user, @template, files, @batch, document_type)
        flash[:notice] = "Your documents are still being processed. Please refresh and start your first task."
        format.json { render json: { status: "ok", link_to: symphony_batch_path(batch_template_name: @template.slug, id: @batch.id, files_count: files.count) } }
      else
        error_message = "There was an error creating this batch. Please contact your admin with details of this error: #{@generate_batch.message}"
        flash[:alert] = error_message
        format.json { render json: { status: "error", message: error_message } }
      end
    end
  end

  def show
    authorize @batch
    # Come from batch uploads (create method)
    @files_count = params[:files_count] if params[:files_count].present?
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
