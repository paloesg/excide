class CustomDeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  default from: 'Excide <info@excide.co>'

  def confirmation_instructions(record, token, opts={})
    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "'+record.email+'"
            }
          ],
          "dynamic_template_data": {
            "firstName": "'+record.email+'"
          }
        }
      ],
      "from": {
        "email": "Excide <info@excide.co>"
      },
      "template_id": "d-908be3573b0a4ea2a20a9b50a01b5b42"
    }')

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._("send").post(request_body: data)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end