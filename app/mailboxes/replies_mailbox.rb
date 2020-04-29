class RepliesMailbox < ApplicationMailbox
  before_processing :find_user

  def process
    return unless @user
    @user.remarks = mail.decoded
    @user.save
  end

  private

  def find_user
    @user = User.find_by(email: mail.from)
  end
end
