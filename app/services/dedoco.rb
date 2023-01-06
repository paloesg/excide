class Dedoco
  include HTTParty
  def initialize(document=nil, task=nil, webhook_params=nil)
    @document = document
    @task = task
    @params = webhook_params
  end

  def run
    begin
      get_jwt_token
      sleep 10
      encode_base64_file_date
      create_document
      append_signing_link
      @document.generate_complete_signing_link
      if @document.save
        send_email_to_signers
      end
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  def run_position_esign
    begin
      generate_visual_builder_link
      sleep 10
      generate_sha3_document_hash
      @document.store_visual_builder_link
      @document.save
      @task.save
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  private

  # Returns link to dedoco visual builder for modifying the position of the signature
  def generate_visual_builder_link
    api_url = "https://developers.stage.dedoco.com/vb/create-project"
    url = "#{ENV["ASSET_HOST"]}/motif/dedoco/webhook"
    base64_fd = Base64.strict_encode64(url)
    @task.dedoco_visual_builder_link = "#{api_url}/#{base64_fd}"
  end

  def generate_sha3_document_hash
    url = @document.raw_file.url
    file_data = URI.open(url)
    doc_hash = SHA3::Digest::SHA256.hexdigest(file_data.read)
    @document.doc_hash = doc_hash
  end

  def get_jwt_token
    url = "https://api.stage.dedoco.com/api/v1/public/auth/token"
    client_auth = {
      username: "f37b138e-a3cf-4d72-b8c8-f683800be842",
      password: "D909C1622777E624CADD6FFC"
    }
    body = {
      fileCallback: "#{ENV["ASSET_HOST"]}/dedoco/webhook",
      statusCallback: "#{ENV["ASSET_HOST"]}/dedoco/webhook"
    }
    res = HTTParty.post(url, body: body, basic_auth: client_auth)
    @document.dedoco_token = res["token"]
    @document.save
  end

  def encode_base64_file_date
    # Problem: File not yet uploaded to S3 but presigned-url is created alr
    url = @document.raw_file.url
    file_data = URI.open(url)
    base64_fd = Base64.strict_encode64(file_data.read)
    @document.base_64_file_data = base64_fd
  end

  def create_document
    # Generate folder
    api_url = "https://api.stage.dedoco.com/api/v1/public/folders"
    body = {
      folder_name: @params["folder_name"],
      date_created: @params["date_created"],
      documents: @params["documents"],
      linked_folders: [],
      business_processes: @params["business_processes"]
    }
    res = HTTParty.post(api_url, headers: {"Content-Type": "application/json", Authorization: "Bearer #{@document.dedoco_token}"}, body: body.to_json)
    @document.dedoco_links = res["links"]
  end

  def append_signing_link
    @encrypt_hash = Base64.strict_encode64("#{ENV["ASSET_HOST"]}/file.json")
    @document.dedoco_complete_signing_link = "#{@document.dedoco_links[0]["link"]}/#{@encrypt_hash}"
  end

  def send_email_to_signers
    @params["business_processes"].each do |bp|
      bp["signers"].each do |signer|
        NotificationMailer.send_esign_document(@document, signer["signer_name"], signer["signer_email"]).deliver_later
      end
    end
  end
end