class Motif::DedocoController < ApplicationController
  # before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  # Webhook from Dedoco
  def create
    # Find document based on document hash saved in database
    @document = Document.find_by(doc_hash: params["documents"][0]["document_hash"])
    if @document.present?
      puts "Returned from Dedoco webhook"
      puts "Returned from Dedoco webhook #{params["folder_name"]}"
      puts "Returned from Dedoco webhook hash params #{params.to_h}"
      puts "Returned from Dedoco #{params}"
      DedocoJob.perform_later(@document, @document.task, "webhook", params)
    else
      puts "No document returned from webhook"
    end
    puts "Returned from Dedoco #{params}"
  end
end
