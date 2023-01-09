class Motif::DedocoController < ApplicationController
  # before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  # Webhook from Dedoco
  def create
    # Find document based on document hash saved in database
    puts "Returned from Dedoco #{params}"
    @document = Document.find_by(doc_hash: params["documents"][0]["document_hash"])
    if @document.present?
      @document.positioned_esign
      @document.save
      DedocoJob.perform_later(@document, @document.task, "webhook", params.to_unsafe_h)
    else
      @document.document_unmatched
      @document.save
    end
    puts "Returned from Dedoco #{params}"
  end
end
