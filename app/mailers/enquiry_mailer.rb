class EnquiryMailer < ApplicationMailer
  default from: 'Sam from Excide <sam@excide.co>'

  def general_enquiries(enquiry)
    @enquiry = enquiry
    address = Mail::Address.new @enquiry.email
    address.display_name = @enquiry.name
    @url  = 'https://calendly.com/sam-excide/'
    mail(to: address.format, subject: 'Thank you for your enquiry')
  end
end
