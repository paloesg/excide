class RepliesMailbox < ApplicationMailbox
  RepliesMailbox::MATCHER = /fileupload-(.+)@symphony.excide.com/i
  before_processing :find_user

  def process
    return unless @user
    # Find the mail.to address (recipient address)
    puts "Company is : #{company}"

    # puts "mail attahcments: #{mail.attachments}"
    # if mail.attachments.empty?
    #   puts "mail attahcments empty: #{mail.attachments}"
    # else
    #   puts "mail attahcments: #{mail.attachments}"
    #   mail.attachments.each do |attachment|
    #     # Get back the latest 
    #     puts 'echo starts'
    #     Document.create(filename: attachment.filename, file_url: "w.e.d", user: @user, company: @user.company)
    #     puts 'echo ends'
    #     # ActiveStorage::Attachment.last.blob.service_url.sub(/\?.*/, '')
    #   end
    # end
    mail.attachments.each do |attachment|
      document = Document.new
      # Add to active storage
      document.converted_image.attach(io: StringIO.new(attachment.body.to_s), filename: attachment.filename,
      content_type: attachment.content_type)
      document.filename = attachment.filename
      document.file_url = attachment.filename
      document.user = @user
      # Get document's company by matching it with company mailbox token
      document.company = company
      document.save
    end
  end

  def company
    @company ||= Company.find_by(mailbox_token: company_mailbox_token)
  end

  def company_mailbox_token
    recipient = mail.recipients.find{|r| MATCHER.match?(r)}
    # Returns the first enclosed capture in the regexp
    recipient[MATCHER, 1]
  end

  private
  # def extract_secrets
  #   # regexp = /.*@(#{SUBDOMAIN_REGEXP}).tiomsu.io/
  #   mail.to.each do |to_address|
  #     match = regexp.match(to_address)
  #     break if match && match[1] == @user.account.subdomain
  #   end
  # end
  def find_user
    @user = User.find_by(email: mail.from)
  end
end
