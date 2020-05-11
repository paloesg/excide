class GenerateDocument
  def initialize(user, company, document_params, template_slug_param, workflow_param, action_param, document_type_param, batch_id)
    @user = user
    @company = company
    @document_params = document_params
    @template_slug_param = template_slug_param
    # Generate document through workflow (with action param) and batches
    @workflow_param = workflow_param
    @action_param = action_param # Only document generated through workflow task will have specific action_param (not batches)
    @document_type_param = document_type_param
    @batch_id = batch_id
  end

  def run
    begin
      create_document
      set_document_associations
      @document.save
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  private

  def create_document
    # Create document with the common parameters
    @document = Document.new(@document_params)
    @document.company = @company
    @document.user = @user
    @document.document_template = DocumentTemplate.find_by(title: 'Invoice') if @document_type_param == 'invoice'
  end

  def set_document_associations
    generate_workflow
    @document.workflow = @workflow

    if @action_param.present?
      # Document belongs to a specific task in workflow
      @workflow_action = @document.company.workflow_actions.find(@action_param)
      @document.workflow_action = @workflow_action
    end

    return @document
  end

  def generate_workflow
    if @document_type_param == 'batch-uploads'
      @template = Template.find(@template_slug_param)
      # Create new workflow
      @workflow = Workflow.new(user: @document.user, company: @document.company, template: @template, workflowable: @client)
      @workflow.template_data(@template)
      @workflow.batch = Batch.find(@batch_id)
      @workflow.save
    elsif @workflow_param.present?
      # Document belongs to workflow
      @workflow = @document.company.workflows.find(@workflow_param)
    end

    return @workflow
  end
end
