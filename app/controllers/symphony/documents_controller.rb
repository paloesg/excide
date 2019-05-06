class Symphony::DocumentsController < DocumentsController
  before_action :set_templates, only: [:index, :new, :edit]
  before_action :set_company_workflows, only: [:index, :new, :edit]
  before_action :set_workflow, only: [:new]

  def index
    # Show the documents by current user roles and documents without a workflow.
    relevant_workflow_ids = @workflows.map{|w| w.id if (w.get_roles & @user.roles).any?}.compact
    @get_documents = @company.documents.where(workflow: relevant_workflow_ids).or(@company.documents.where(workflow: nil)).includes(:document_template, :workflow)
    @documents = Kaminari.paginate_array(@get_documents.sort_by{ |a| a.created_at }.reverse!).page(params[:page]).per(20)
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end

  def edit
    @workflow = @workflows.find(@document.workflow_id) if @document.workflow_id.present?
  end

  def create
    @document = Document.new(document_params)
    @document.company = @company
    @document.user = @user
    @document.document_template = DocumentTemplate.find_by(title: 'Invoice') if params[:document_type] == 'invoice'
    if params[:workflow].present?
      @workflow = Workflow.find_by(identifier: params[:workflow])
      @document.workflow = @workflow
    end

    respond_to do |format|
      if @document.save
        if params[:document_type] == 'invoice'
          @template = Template.find(params[:document][:template_id])
          @workflow = Workflow.new(user: current_user, company: @company, template: @template, identifier: @document.identifier, workflowable: @client)
          @workflow.template_data(@template)
          @workflow.save
          @document.update_attributes(workflow: @workflow)
          #number of documents uploaded in the dropzone
          @number_of_documents = params[:count]
          #get the latest batch identifier and pass it as a params
          @latest_batch = Batch.last
          #this will trigger assign workflow to batches in batches controller
          format.html { redirect_to symphony_assign_workflows_to_batch_path(batch_identifier: @latest_batch.batch_identifier, workflow_name: @template.slug, workflow_identifier: @workflow.identifier)}
        else
          format.html { redirect_to @workflow.nil? ? symphony_documents_path : symphony_workflow_path(@workflow.template.slug, @workflow.identifier), notice: 'Document was successfully created.' }
          format.json { render :show, status: :created, location: @document}
        end
      else
        set_templates

        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @document.update(document_params)
      redirect_to symphony_document_path, notice: 'Document was successfully updated.'
    else
      set_templates
      render :edit
    end
  end

  def destroy
    @document.destroy
    redirect_to symphony_documents_path, notice: 'Document was successfully destroyed.'
  end

  def upload_invoice
    set_company
    set_company_workflows
    @clients = @company.clients
    @templates = Template.assigned_templates(current_user)
    @s3_direct_post = S3_BUCKET.presigned_post(key: "#{@company.slug}/uploads/#{SecureRandom.uuid}/${filename}", allow_any: ['utf8', 'authenticity_token'], success_action_status: '201', acl: 'public-read')
  end

  private

  def set_company
    @user = current_user
    @company = @user.company
  end

  def set_templates
    @document_templates = DocumentTemplate.joins(template: :company).where(templates: {company_id: @company.id}).order(id: :asc)
  end

  def set_company_workflows
    @workflows = @company.workflows.includes(template: [{ sections: [{ tasks: :role }] }])
  end

  def set_workflow
    @workflow = @workflows.find_by(identifier: params[:workflow]) if params[:workflow].present?
  end
end
