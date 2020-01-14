class Enquiry < ApplicationRecord

  validates :name, :email, presence: true

  def self.yesterday
    enquiries = Enquiry.where('DATE(created_at) = ?', Date.yesterday)
  end
end