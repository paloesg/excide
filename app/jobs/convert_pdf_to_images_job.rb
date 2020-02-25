class ConvertPdfToImagesJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(document)
    # Do something later
    ConversionService.new(document).run
  end
end
