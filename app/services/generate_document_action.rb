class GenerateDocumentAction
  def initialize(document, user, company, workflow_param, action_param, document_type_param, document_template_param)
    @document = document
    @user = user
    @company = company
    @workflow_param = workflow_param
    @action_param = action_param
    @document_type_param = document_type_param
    @document_template_param = document_template_param
  end

  def run
    set_common_document_attributes
    set_document_associations
  end

  private

  def set_common_document_attributes
    @document.company = @company
    @document.user = @user
    @document.document_template = DocumentTemplate.find_by(title: 'Invoice') if @document_type_param == 'invoice'
  end

  def set_document_associations
    if @document_type_param == 'batch-uploads'
      @template = Template.find(@document_template_param)
      @workflow = Workflow.new(user: @document.user, company: @document.company, template: @template, workflowable: @client)
      @workflow.template_data(@template)
      # Set workflow to belong to the most recently created batch
      # TODO: Fix concurrency issues if 2 people create batch at the same time
      @workflow.batch = Batch.last
      @workflow.save
      @document.workflow = @workflow
    elsif @workflow_param.present?
      # Document belongs to workflow
      @workflow = @document.company.workflows.find(@workflow_param)
      @document.workflow = @workflow

      if @action_param.present?
        # Document belongs to a specific task in workflow
        @workflow_action = @document.company.workflow_actions.find(@action_param)
        @document.workflow_action = @workflow_action
      end
    end

    return @document
  end
end
