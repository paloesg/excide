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
          name: "dummy.pdf",
          file_type: "pdf",
          document_hash: SHA3::Digest::SHA256.hexdigest(File.binread("./dummy.pdf"))
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
    res = HTTParty.post(url, headers: {"Content-Type": "application/json", Authorization: "Bearer #{@document.dedoco_token}"}, body: body.to_json)
    puts "Response message: #{res["links"]}"
    @document.dedoco_links = res["links"]
    @document.save
    # [{"documentId"=>"63acf6e4396122001ec1141b", "documentName"=>"updated_heritance_6.3.pdf", "businessProcessId"=>"63acf6e4396122001ec1141c", "signerId"=>"3c91504f-0d07-4989-99aa-b748e1425b07", "signerName"=>"san", "signerEmail"=>"san@gmail.com", "link"=>"https://sign.stage.dedoco.com/public/sign/63acf6e4396122001ec1141c/3c91504f-0d07-4989-99aa-b748e1425b07"}]
  end

  def append_signing_link
    @encrypt_hash = Base64.strict_encode64("https://0784-122-11-205-174.ngrok.io/motif/documents/34f07dd1-2d4d-4efd-882c-a111ad9b9928/file")
    @link = "#{@document.dedoco_links[0]["link"]}/#{@encrypt_hash}"
    puts "What is link: #{@link}"
  end
end