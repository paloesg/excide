class ConversionService
  # This service is to convert things. Eg PDF document converts to images
  require "mini_magick"
  def initialize(document)
    @document = document
  end

  def run
    begin
      convert_to_image
      @document.save
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  private
  def convert_to_image
    if @document.raw_file.content_type == "application/pdf"
      url = @document.raw_file.service_url
      page_count = MiniMagick::Image.open(url).pages.count
      page_count.times do |page_number|
        result = ImageProcessing::MiniMagick.source(url).loader(page: page_number).append("-density", 300).append("-flatten").append("-quality", 90).convert("png").call
        @document.converted_image.attach(io: result, filename: result.path.split('/').last, content_type: "image/png")
      end
    end
  end
end

