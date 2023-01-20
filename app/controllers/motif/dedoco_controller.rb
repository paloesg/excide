class Motif::DedocoController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Webhook from Dedoco
  def create
    # Store webhook return in a session variable
    puts "Webhook dedoco! "
    if params["documents"].present?
      Session.create(document_hash: params["documents"][0]["document_hash"], data: params.to_unsafe_hash)
    else
      @document = Document.find_by(dedoco_business_processes_id: params["businessProcessId"])
      if @document.present?
        # Change status of document to signed
        @document.sign_document unless @document.signed?
        decoded_pdf = Base64.decode64(params["file"])
        # Create a new blob object from the decoded PDF
        blob = ActiveStorage::Blob.create_after_upload!(
          io: StringIO.new(decoded_pdf),
          filename: "signed_#{@document.raw_file.filename}",
          content_type: "application/pdf"
        )
        # Attach the signed blob to the documents
        @document.signed_versions.attach(blob)
        @document.save
      end
    end
  end
end
