class GenerateWorkflowsService
  def initialize(user, template, document_ids, batch)
    @user = user
    @template = template
    @document_ids = document_ids
    @batch = batch
  end

  def run
    begin
      set_document_associations
      OpenStruct.new(success?: true, batch: @batch)
    rescue => e
      OpenStruct.new(success?: false, message: e.message)
    end
  end

  private

  def set_document_associations
    @document_ids.each do |document_id|
      @document = Document.find_by(id: document_id)
      generate_workflow
      @document.workflow = @workflow
      @document.save
    end
  end

  def generate_workflow
    # Create new workflow
    @workflow = Workflow.new(user: @user, company: @user.company, template: @template)
    @workflow.template_data(@template)
    @workflow.batch = Batch.find(@batch.id)
    @workflow.save

    return @workflow
  end
end
