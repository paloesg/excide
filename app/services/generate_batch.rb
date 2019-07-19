class GenerateBatch
  def initialize(user, template, filename, file_url)
    @user = user
    @template = template
    @filename = filename
    @file_url = file_url
  end

  def run
    generate_batch
    generate_workflow(batch)
    generate_documents(workflow)
  end

  private

  def generate_batch
    batch = Batch.create(user: @user, template: @template, company: @user.company)
    return batch
  end

  def generate_workflow(batch)
    workflow = Workflow.new(user: @user, compny: @user.company, template: @template, batch: batch)
    workflow.template_data(@template)
    workflow.save
    return workflow
  end

  def generate_documents(workflow)
    Document.create(filename: @filename, company: @user.company, file_url: @file_url, workflow: workflow)
  end
end