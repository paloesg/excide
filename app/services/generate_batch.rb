class GenerateBatch
  def initialize(user, template, company)
    @user = user
    @template = template
    @company = company
  end

  def run
    generate_batch
  end

  private
  def generate_batch
    Batch.create(user: @user, template: @template, company: @company)
  end
end