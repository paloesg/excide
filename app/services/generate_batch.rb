class GenerateBatch
  def initialize(user, template)
    @user = user
    @template = template
  end

  def run
    begin
      generate_batch
      OpenStruct.new(success?: true, batch: @batch)
    rescue => e
      OpenStruct.new(success?: false, batch: @batch, message: e.message)
    end
  end

  private

  def generate_batch
    @batch = Batch.create(user: @user, template: @template, company: @user.company)
  end
end