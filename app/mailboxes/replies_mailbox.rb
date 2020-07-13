class RepliesMailbox < ApplicationMailbox
  RepliesMailbox::MATCHER = /sendfile-(.+)@upload.#{Regexp.escape(ENV['EMAIL_UPLOAD_DOMAIN'])}/i
  # Verify that user is in Symphony database
  before_processing :find_user

  def process
    return unless @user
    # The assumption is that there will be attachment when user send the email to mailbox
    mail.attachments.each do |attachment|
      document = Document.new
      # Add to active storage
      document.raw_file.attach(io: StringIO.new(attachment.body.to_s), filename: attachment.filename, content_type: attachment.content_type)
      document.user = @user
      # Get document's company by matching it with company mailbox token
      document.company = company
      document.save
      # Tagged document
      document.tag_list.add('Email')
      # Run conversion
      ConversionService.new(document).run
    end
  end

  def company
    @company ||= Company.find_by(mailbox_token: company_mailbox_token)
  end

  def company_mailbox_token
    # Find the recipient which email matches the regexp
    recipient = mail.recipients.find{|r| MATCHER.match?(r)}
    # Recipient returns output like this: ["sendfile-<MAILBOX_TOKEN>@upload.#{ENV['HOST_DOMAIN']}"]
    # Returns the first enclosed capture (which is the mailbox token) in the regexp
    recipient[MATCHER, 1]
  end

  private
  def find_user
    @user = User.find_by(email: mail.from)
  end
end
