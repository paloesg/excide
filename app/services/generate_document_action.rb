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
    @document.company = @company
    @document.user = @user
    @document.document_template = DocumentTemplate.find_by(title: 'Invoice') if @document_type_param == 'invoice'
    if @workflow_param.present?
      @workflow = @document.company.workflows.find(@workflow_param)
      @document.workflow = @workflow
    end

    if @action_param.present?
      @workflow_action = @document.company.workflow_actions.find(@action_param)
      @document.workflow_action = @workflow_action
    end

    if @document_type_param == 'batch-uploads'
      @template = Template.find(@document_template_param)
      @workflow = Workflow.new(user: @document.user, company: @document.company, template: @template, workflowable: @client)
      @workflow.template_data(@template)
      #equate workflow to the latest batch
      @workflow.batch = Batch.last
      @workflow.save
      @document.workflow = @workflow
    end
    return @document
  end

  private
end