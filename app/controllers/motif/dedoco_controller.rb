class Motif::DedocoController < ApplicationController
  # before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  # Webhook from Dedoco
  def create
    # Find document based on document hash saved in database
    puts "Returned from Dedoco #{params}"
    # After user has signed the document
    if params["file"].present?
      @document = Document.find_by(doc_hash: params["businessProcessId"])
      # # Decode the base64 encoded PDF
      decoded_pdf = Base64.decode64(params["file"])
      # # Create a new blob object from the decoded PDF
      blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new(decoded_pdf),
        filename: "decoded.pdf",
        content_type: "application/pdf"
      )
      # Attach the signed blob to the documents
      @document.signed_versions.attach(blob)
    else
      @document = Document.find_by(doc_hash: params["documents"][0]["document_hash"])
      if @document.present?
        @document.positioned_esign
        @document.save
        DedocoJob.perform_later(@document, @document.task, "webhook", params.to_unsafe_h)
      end
    end
  end
end
