class GenerateBatch
  def initialize(user, template)
    @user = user
    @template = template
  end

  def run
    generate_batch
  end

  private

  def generate_batch
    batch = Batch.create(user: @user, template: @template, company: @user.company)
  end
end