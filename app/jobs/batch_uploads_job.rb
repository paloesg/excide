class BatchUploadsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(user, template, files, batch, document_type)
    # Loop through all the file and generate documents
    files.each do |file|
      puts "Response Key: #{file['response']['key']}"
      @generate_document = GenerateDocument.new(user, user.company, template.slug, nil, nil, document_type, batch.id).run
      puts "What is generate document? #{@generate_document.document}"
      if @generate_document.success?
        document = @generate_document.document
        # attach and convert method
        document.attach_and_convert_document(file['response']['key'])
      end
    end
  end
end
