class Availability < ActiveRecord::Base
  belongs_to :user

  validates :available_date, :start_time, :end_time, presence: true
end
