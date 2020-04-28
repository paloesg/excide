class RepliesMailbox < ApplicationMailbox
  before_processing :find_user

  def process
    return unless @user
    puts "MAIL DECODED: #{mail.decoded}"
  end

  private

  def find_user
    @user = User.find_by(email: mail.from)
  end
end
