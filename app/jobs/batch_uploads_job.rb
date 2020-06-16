class BatchUploadsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(user, template, files, batch, document_type)
    # Loop through all the file and generate documents
    files.each do |file|
      @generate_document = GenerateDocument.new(user, user.company, template.slug, nil, nil, document_type, batch.id).run
      blob = ActiveStorage::Blob.find_by(key: file['response']['key'])
      # Check that document is generated properly before attaching and converting. It wont attach if document is not generated
      if @generate_document.success?
        @generate_document.document.attach_and_convert_document(file['response']['key'])
        blob.has_document = true
      else
        blob.has_document = false
      end
      blob.save
    end
    batch.batch_upload
    batch.save
  end
end
