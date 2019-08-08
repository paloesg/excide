class GenerateDocumentAction
  def initialize(user, company, workflow_param, action_param, document_params, document_type_param, document_template_param, batch_id)
    @user = user
    @company = company
    @workflow_param = workflow_param
    @action_param = action_param
    @document_params = document_params
    @document_type_param = document_type_param
    @document_template_param = document_template_param
    @batch_id = batch_id
  end

  def run
    begin
      set_common_document_attributes
      set_document_associations
      @document.save
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  private

  def set_common_document_attributes
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
      @template = Template.find(@document_template_param)
      @batch = Batch.find(@batch_id)
      # Create new workflow
      @workflow = Workflow.new(user: @document.user, company: @document.company, template: @template, workflowable: @client)
      @workflow.template_data(@template)
      # Set workflow to belong to the most recently created batch
      # TODO: Fix concurrency issues if 2 people create batch at the same time
      @workflow.batch = @batch
      @workflow.save
    elsif @workflow_param.present?
      # Document belongs to workflow
      @workflow = @document.company.workflows.find(@workflow_param)
    end

    return @workflow
  end
end
