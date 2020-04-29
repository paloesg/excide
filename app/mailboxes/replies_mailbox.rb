class RepliesMailbox < ApplicationMailbox
  before_processing :find_user

  def process
    return unless @user
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
      blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new(attachment.body.to_s),
        filename: attachment.filename,
        content_type: attachment.content_type
      )
      # Document.create(filename: attachment.filename, file_url: )
    end
    # puts "mailcatcher mailbox: #{mail}"
  end

  private

  def find_user
    @user = User.find_by(email: mail.from)
  end
end
