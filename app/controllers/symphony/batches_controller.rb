class Symphony::BatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_batch, only: [:show, :destroy]
  before_action :set_s3_direct_post, only: [:show, :new]

  after_action :verify_authorized, except: [:index, :create, :create_batches_through_email]
  after_action :verify_policy_scoped, only: :index

  def index
    @templates = policy_scope(Template).assigned_templates(current_user).where(template_pattern: "on_demand")
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
    if params[:source] == 'upload'
      @template = Template.find_by(slug: params[:batch][:template_slug])
      files = JSON.parse(params[:successful_results])['successful']
      document_type = params[:document_type]
    else
      @template = Template.find_by(slug: params[:template_slug])
    end
    # Add attributes of batches
    @batch = Batch.new(user: current_user, template: @template, company: current_user.company)
    # authorize @generate_batch.batch
    respond_to do |format|
      if @batch.save!
        if params[:source] == 'email'
          @generate_batch = GenerateWorkflowsService.new(current_user, @template, params[:tag_ids], @batch).run
          @generate_batch.success? ? (format.html{ redirect_to symphony_batch_path(batch_template_name: @template.slug, id: @generate_batch.batch.id, document_count: params[:tag_ids].count), notice: 'Batches created successfully.'}) : ( format.html { redirect_to symphony_documents_path, alert: "An error occurs while creating batch: #{@generate_batch.message}"})
        else
          # Run background job to generate documents
          BatchUploadsJob.perform_later(current_user, @template, files, @batch, document_type)
          flash[:notice] = "Your documents are still being processed. Please refresh and start your first task."
          format.json { render json: { status: "ok", link_to: symphony_batch_path(batch_template_name: @template.slug, id: @batch.id, files_count: files.count) } }
        end
      else
        error_message = "There was an error creating this batch. Please contact your admin with details of this error: #{@generate_batch.message}"
        flash[:alert] = error_message
        format.json { render json: { status: "error", message: error_message } }
      end
    end
  end

  def show
    authorize @batch
    # Come from batch uploads (create method). [number, 0].max() is to prevent negative number from being passed in
    @processing_files = [(params[:files_count].to_i - @batch.workflows.count), 0].max() if params[:files_count].present?
    @completed = @batch.workflows.where(completed: true).length
    # This comes from create batch through email method
    @document_count = params[:document_count] if params[:document_count].present?
    
    @per_batch = Kaminari.paginate_array(@batch.workflows.includes(:documents, :invoice, :template, :company).order(created_at: :asc)).page(params[:page]).per(10)
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
