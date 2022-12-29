class Dedoco
  include HTTParty
  def initialize(document)
    @document = document
  end

  def get_jwt_token
    url = "https://api.stage.dedoco.com/api/v1/public/auth/token"
    client_auth = {
      username: "f37b138e-a3cf-4d72-b8c8-f683800be842",
      password: "D909C1622777E624CADD6FFC"
    }
    body = {
      fileCallback: "https://webhook.site/d76b4930-ae2d-4893-ae71-4c1d5da3c48c",
      statusCallback: "https://webhook.site/d76b4930-ae2d-4893-ae71-4c1d5da3c48c"
    }
    res = HTTParty.post(url, body: body, basic_auth: client_auth)
    @document.dedoco_token = res["token"]
    @document.save
  end

  def create_document
    # Generate folder
    url = "https://api.stage.dedoco.com/api/v1/public/folders"
    body = {
      folder_name: "Test Folder",
      date_created: DateTime.current.to_i,
      documents: [
        {
          name: @document.raw_file.filename.to_s,
          file_type: "pdf",
          document_hash: SHA3::Digest::SHA256.hexdigest(@document.raw_file.url)
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
              signer_name: "san",
              signer_email: "san@gmail.com",
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
    puts "what is bearer: #{"Bearer #{@document.dedoco_token}"}"
    res = HTTParty.post(url, headers: {"Content-Type": "application/json", Authorization: "Bearer #{@document.dedoco_token}"}, body: body.to_json)
      # , headers: {Authorization: "Bearer #{@document.dedoco_token}"})
    puts "Response message: #{res}"
  end
end