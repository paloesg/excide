class GenerateBatch
  def initialize(user, template, params_batch)
    @user = user
    @template = template
    @params_batch = params_batch
    @company = @user.company
  end

  def run

    begin
      Batch.transaction do
        generate_batch
        generate_documents
      end
      OpenStruct.new(success?: true, batch: @batch)
    rescue => e
      OpenStruct.new(success?: false, batch: @batch, message: e.message)
    end
  end

  private

  def generate_batch
    @batch = Batch.create(user: @user, template: @template, company: @user.company)
  end

  def generate_documents
    @params_batch[:document_attributes].each do |k, v|
      @document = Document.new(filename: v['document']['filename'], file_url: v['document']['file_url'])
      @document.company = @company
      @document.user = @user
      generate_workflows
      @document.workflow = @workflow
      @document.save
    end
  end

  def generate_workflows
    @workflow = Workflow.new(user: @user, company: @company, template: @template, workflowable: @client)
    @workflow.template_data(@template)
    # Set workflow to belong to the most recently created batch
    # TODO: Fix concurrency issues if 2 people create batch at the same time
    @workflow.batch = @batch
    @workflow.save
  end
end