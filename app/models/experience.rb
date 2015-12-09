class Experience < ActiveRecord::Base
  belongs_to :profile

  validates :title, :company, :start_date, presence: true
end
