class Dedoco
  include HTTParty
  def initialize(document=nil, task=nil, webhook_params=nil)
    @document = document
    @task = task
    @params = webhook_params || nil
  end

  def run
    begin
      get_jwt_token
      create_document
      append_signing_link
      @document.save
      # if @document.save!
      #   NotificationMailer.send_esign_document(@document).deliver_later
      # end
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
    puts "Hash 1"
    url = @document.raw_file.url
    puts "Hash 2 #{url}"
    file_data = URI.open(url)
    puts "Hash 3"
    doc_hash = SHA3::Digest::SHA256.hexdigest(file_data.read)
    puts "Hash 4"
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

  def create_document
    # Generate folder
    api_url = "https://api.stage.dedoco.com/api/v1/public/folders"
    body =
    # {
    #   folder_name: @params["folder_name"],
    #   date_created: @params["date_created"],
    #   documents: @params["documents"],
    #   linked_folders: [],
    #   business_processes: @params["business_processes"]
    # }


    # {
    #   folder_name: "Jin",
    #   date_created: 1672904260,
    #   documents: [
    #     {
    #       name: "updated_heritance_6.3.pdf",
    #       file_type: "pdf",
    #       document_hash: "c0e4fe5ca4d847832d6f42ef3fa87e630d76ae2340b26c44a5a3bff5ec26ba4d"
    #     }
    #   ],
    #   linked_folders: [],

    #   business_processes: [
    #     {
    #       type: "signature",
    #       expiration_time: 1674113860,
    #       document_id: 0,
    #       signers: [
    #         {
    #           signer_name: "JOn",
    #           signer_email: "jonathan.lau@paloe.com.sg",
    #           signer_phone: "",
    #           signer_nric: "",
    #           esignatures: [
    #             {
    #               is_mandatory: true,
    #               placement: {
    #                 page: 1,
    #                 x: "0.697930142302717",
    #                 y: "0.06781307129798902"
    #               },
    #               dimensions: {
    #                 width: "0.258732212160414",
    #                 height: "0.0712979890310786"
    #               }
    #             }
    #           ],
    #           custom_texts: [],
    #           digi_signatures: [],
    #           sequence_number: 1
    #         }
    #       ],
    #       is_sequential: false,
    #       observers: [],
    #       completion_requirement: {
    #         min_number: 1
    #       }
    #     }
    #   ]
    # }

    res = HTTParty.post(api_url, headers: {"Content-Type": "application/json", Authorization: "Bearer #{@document.dedoco_token}"}, body: body.to_json)
    @document.dedoco_links = res["links"]
  end

  def append_signing_link
    @encrypt_hash = Base64.strict_encode64("#{ENV["ASSET_HOST"]}/file.json")
    @document.dedoco_complete_signing_link = "#{@document.dedoco_links[0]["link"]}/#{@encrypt_hash}"
  end
end