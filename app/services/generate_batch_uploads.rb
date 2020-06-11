class GenerateBatchUploads
  def initialize(user, template, files)
    @user = user
    @template = template
    @files = files
  end

  def run
    begin
      generate_batch
      generate_documents
      @batch.save
      OpenStruct.new(success?: true, batch: @batch)
    rescue => e
      OpenStruct.new(success?: false, batch: @batch, message: e.message)
    end
  end

  private

  def generate_batch
    
  end
end
