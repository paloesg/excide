class GenerateTextract
  def initialize(document_id)
    @document_id = document_id
  end

  def run_generate
    begin
      get_document
      generate_textract
      @document.save
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  def run_analyze
    begin
      get_document
      analyze_document
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  private

  def get_document
    @document = Document.find(@document_id)
  end

  def generate_textract
    # get object file location and name
    s3_uri = URI.parse(@document.file_url)
    s3_uri.path.slice!(0)
    file_name = s3_uri.path
    # example: "excide/uploads/3d8ff957-532b-4f37-8fbe-9baa522d337c/191126-fuji-xerox-250-87.pdf"

    # asynchronus operation
    resp = AWS_TEXTRACT.start_document_analysis({
      document_location: {
        s3_object: {
          bucket: ENV['S3_BUCKET'],
          name: file_name
        }
      },
      feature_types: ["TABLES"],
      job_tag: "Receipt",
    })
    @document.aws_textract_job_id = resp[:job_id]
  end

  def analyze_document
    job_id = params[:job_id]
    @textract_json = AWS_TEXTRACT.get_document_analysis({
      job_id: job_id.to_s
    })
    return @textract_json
  end

end