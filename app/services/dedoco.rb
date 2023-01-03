class Dedoco
  include HTTParty
  def initialize(document)
    @document = document
  end

  def run
    begin
      get_jwt_token
      return_dedoco_link
      # sleep 10
      # encode_base64_file_date
      # create_document
      # append_signing_link
      # @document.save
      # if @document.save!
      #   NotificationMailer.send_esign_document(@document).deliver_later
      # end
      OpenStruct.new(success?: true, document: @document)
    rescue => e
      OpenStruct.new(success?: false, document: @document, message: e.message)
    end
  end

  private

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

  def return_dedoco_link
    api_url = "https://developers.stage.dedoco.com/vb/create-project"
    url = "#{ENV["ASSET_HOST"]}/dedoco/webhook"
    file_data = URI.open(url)
    base64_fd = Base64.strict_encode64(file_data.read)
    @document.dedoco_complete_signing_link = "#{api_url}/#{base64_fd}"
    @document.save
    # res = HTTParty.post("#{api_url}/#{base64_fd}", headers: {"Content-Type": "application/json", Authorization: "Bearer #{@document.dedoco_token}"}, body: body.to_json)
  end

  def encode_base64_file_date
    # puts "Is document attached? #{@document.raw_file.attached?}"
    # Problem: File not yet uploaded to S3 but presigned-url is created alr
    url = @document.raw_file.url
    file_data = URI.open(url)
    base64_fd = Base64.strict_encode64(file_data.read)
    @document.base_64_file_data = base64_fd
  end

  def create_document
    # Generate folder
    api_url = "https://api.stage.dedoco.com/api/v1/public/folders"
    url = @document.raw_file.url
    file_data = URI.open(url)
    body = {
      folder_name: "Test Folder",
      date_created: DateTime.current.to_i,
      documents: [
        {
          name: @document.raw_file.filename.to_s,
          file_type: "pdf",
          document_hash: SHA3::Digest::SHA256.hexdigest(file_data.read)
        }
      ],
      # linked_folders: [],
      business_processes: [
        {
          type: "signature",
          expiration_time: 0,
          document_id: 0,
          signers: [
            {
              signer_name: "Jonathan",
              signer_email: "jonathan.lau@paloe.com.sg",
              signer_phone: "",
              signer_nric: "",
              esignatures: [
                {
                  is_mandatory: true,
                  placement: {
                    page: 1,
                    x: "0.684993531694696",
                    y: "0.3461280278793419"
                  },
                  dimensions: {
                    width: "0.258732212160414",
                    height: "0.0712979890310786"
                  }
                }
              ],
              custom_texts: [
                {
                  is_mandatory: true,
                  placement: {
                    page: 1,
                    x: "0.682406209573092",
                    y: "0.2821426531078611"
                  },
                  dimensions: {
                    width: "0.258732212160414",
                    height: "0.04570383912248629"
                  },
                  descriptor: "Actual Date",
                  type: "actual-date"
                }
              ],
              digi_signatures: [],
              sequence_number: 1
            }
          ],
          is_sequential: false,
          observers: [],
          completion_requirement: {
            min_number: 1
          }
        }
      ]
    }
    res = HTTParty.post(api_url, headers: {"Content-Type": "application/json", Authorization: "Bearer #{@document.dedoco_token}"}, body: body.to_json)
    @document.dedoco_links = res["links"]
  end

  def append_signing_link
    @encrypt_hash = Base64.strict_encode64("#{ENV["ASSET_HOST"]}/file.json")
    @document.dedoco_complete_signing_link = "#{@document.dedoco_links[0]["link"]}/#{@encrypt_hash}"
  end
end