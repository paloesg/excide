class GenerateBatch
  def initialize(user, template)
    @user = user
    @template = template
  end

  def run
    begin
      generate_batch
      @batch.save
      OpenStruct.new(success?: true, batch: @batch)
    rescue => e
      OpenStruct.new(success?: false, batch: @batch, message: e.message)
    end
  end

  private

  def generate_batch
    @batch = Batch.new
    @batch.user_id = @user.id
    @batch.template_id = @template.id
    @batch.company_id = @user.company.id
  end
end