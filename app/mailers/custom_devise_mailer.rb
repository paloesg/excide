class CustomDeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

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
        "email": "Paloe Symphony <admin@excide.co>"
      },
      "template_id": "'+ENV['SENDGRID_CONFIRMATION_EMAIL_TEMPLATE']+'"
    }')

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    begin
      sg.client.mail._("send").post(request_body: data)
    rescue Exception => e
      puts e.message
    end
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
        "email": "Paloe Symphony <admin@excide.co>"
      },
      "template_id": "'+ENV['SENDGRID_UNLOCK_ACCOUNT_EMAIL_TEMPLATE']+'"
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
        "email": "Paloe Symphony <admin@excide.co>"
      },
      "template_id": "'+ENV['SENDGRID_RESET_PASSWORD_EMAIL_TEMPLATE']+'"
    }')

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._("send").post(request_body: data)
  end
end
