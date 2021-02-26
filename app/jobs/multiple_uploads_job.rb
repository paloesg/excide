class MultipleUploadsJob < ApplicationJob
  # This background job is for multiple file uploads, used in dataroom only at the moment
  include SuckerPunch::Job
  queue_as :default

  def perform(user, uploaded_files, document_type, folder_id)
    admin_role = Role.find_by(resource: user.company, name: "admin")
    uploaded_files.each do |file|
      @generate_document = GenerateDocument.new(user, user.company, nil, nil, nil, document_type, nil, folder_id).run
      document = @generate_document.document
      # attach and convert method with the response key to create blob
      document.attach_and_convert_document(file['response']['key'])
      # attach the document as the 1st version (for version history)
      document.versions.attach(file['response']['signed_id'])
      # Make the attachment the current (first) version
      document.versions.attachments.first.current_version = true
      document.versions.attachments.first.save
      # Create document permissions for all admin users
      Permission.create(role: admin_role, can_write: true, can_download: true, can_view: true, permissible: document)
    end
  end
end
