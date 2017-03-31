class EnquiryMailer < ApplicationMailer
  default from: 'Sam from Excide <sam@excide.co>'

  def general_enquiries(enquiry)
    @enquiry = enquiry
    @url  = 'http://example.com/login'
    mail(to: @enquiry.email, subject: 'Thank you for your enquiry')
  end
end
