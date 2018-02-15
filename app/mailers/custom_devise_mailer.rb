class CustomDeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  default from: 'Excide <info@excide.co>'

  def confirmation_instructions(record, token, opts={})
    opts[:subject] = 'Please activate your Excide Symphony account'
    super
  end
end