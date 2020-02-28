# Preview all emails at http://localhost:3000/rails/mailers/enquiry_mailer
class EnquiryMailerPreview < ActionMailer::Preview
  def general_enquiry
    EnquiryMailer.general_enquiry(Enquiry.last)
  end

  def template_enquiry
    EnquiryMailer.template_enquiry(Enquiry.last)
  end
end