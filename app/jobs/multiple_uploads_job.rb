class MultipleUploadsJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(user, uploaded_files, document_type, wfa)
    uploaded_files.each do |file|
      @generate_document = GenerateDocument.new(user, user.company, nil, nil, nil, document_type, nil, wfa.task.folder&.id).run_without_associations
      if @generate_document.success?
        document = @generate_document.document
        document.update_attributes(workflow_action_id: wfa.id, folder_id: wfa.task.folder&.id)
        # attach and convert method
        document.attach_and_convert_document(file['response']['key'])
        # Create custom activity when upload document in motif
        document.create_activity key: 'workflow.motif_document_uploads', owner: user, recipient: wfa.workflow, params: { instructions: wfa.task.instructions  }
      end
    end
  end
end
