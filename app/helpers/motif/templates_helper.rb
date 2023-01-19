module Motif::TemplatesHelper
  # Returns link to dedoco visual builder for modifying the position of the signature
  def generate_visual_builder_link
    api_url = "https://developers.stage.dedoco.com/vb/create-project"
    url = "#{ENV["ASSET_HOST"]}/motif/dedoco/webhook"
    base64_fd = Base64.strict_encode64(url)
    "#{api_url}/#{base64_fd}"
  end
end
