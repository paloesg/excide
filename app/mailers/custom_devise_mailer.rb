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
            "firstName": "'+record.email+'",
            "confirmationToken": "'+token+'"
          }
        }
      ],
      "from": {
        "email": "Excide <info@excide.co>"
      },
      "template_id": "d-908be3573b0a4ea2a20a9b50a01b5b42"
    }')

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._("send").post(request_body: data)
  end
  
  def unlock_instructions(record, token, opts={})
    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "'+record.email+'"
            }
          ],
          "dynamic_template_data": {
            "firstName": "'+record.email+'",
            "unlockToken": "'+token+'"
          }
        }
      ],
      "from": {
        "email": "Excide <info@excide.co>"
      },
      "template_id": "d-ba990131f20f4ad4b4eda3eb9d804d1f"
    }')

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._("send").post(request_body: data)
  end

  def reset_password_instructions(record, token, opts={})
    data = JSON.parse('{
      "personalizations": [
        {
          "to": [
            {
              "email": "'+record.email+'"
            }
          ],
          "dynamic_template_data": {
            "firstName": "'+record.email+'",
            "resetToken": "'+token+'"
          }
        }
      ],
      "from": {
        "email": "Excide <info@excide.co>"
      },
      "template_id": "d-7ffeac72f25e454dbf2bc76e4b3c3314"
    }')

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._("send").post(request_body: data)
  end
end