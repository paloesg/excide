class Enquiry < ApplicationRecord

  validates :name, :contact, :email, presence: true

  def self.yesterday
    enquiries = Enquiry.where('DATE(created_at) = ?', Date.yesterday)
  end
end