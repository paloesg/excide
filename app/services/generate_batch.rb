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
    @batch.user = @user
    @batch.template = @template
    @batch.company = @user.company
  end
end