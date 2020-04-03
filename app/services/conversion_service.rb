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
    if File.extname(@document.file_url) == ".pdf"
      page_count = MiniMagick::Image.open("https:" + @document.file_url).pages.count
      page_count.times do |page_number|
        result = ImageProcessing::MiniMagick.source("https:" + @document.file_url).loader(page: page_number).custom{|magick| magick.colorspace("RBG")}.append("-density", 300).append("-flatten").append("-quality", 90).convert("png").call
        @document.converted_image.attach(io: result, filename: result.path.split('/').last, content_type: "image/png")
      end
    end
  end
end

