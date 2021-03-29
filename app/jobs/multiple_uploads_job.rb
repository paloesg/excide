class MultipleUploadsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  # This method is to run background job for ADA multiple file upload. Ran from workflow_controller upload_documents method and documents create method
  def perform(user, uploaded_files, document_type, wfa, folder_id)
    uploaded_files.each do |file|
      # Comes from the wfa's drawer in workflows
      if wfa.present?
        @generate_document = GenerateDocument.new(user, user.company, nil, nil, nil, document_type, nil, wfa.task.folder&.id).run_without_associations
        if @generate_document.success?
          document = @generate_document.document
          document.update(workflow_action_id: wfa.id, folder_id: wfa.task.folder&.id)
          # Create custom activity when upload document in motif
          document.create_activity key: 'workflow.motif_document_uploads', owner: user, recipient: wfa.workflow, params: { instructions: wfa.task.instructions  }
        end
      # Comes from communication hub multiple uploads
      else
        @generate_document = GenerateDocument.new(user, user.company, nil, nil, nil, document_type, nil, folder_id).run_without_associations
        document = @generate_document.document if @generate_document.success?
      end
      # attach and convert method
      document.attach_and_convert_document(file['response']['key'])
    end
  end
end
