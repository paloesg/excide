class Enquiry < ActiveRecord::Base
  def self.yesterday
    enquiries = Enquiry.where('DATE(created_at) = ?', Date.yesterday)
  end
end
