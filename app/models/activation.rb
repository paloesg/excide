class Activation < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

  validates :start_time, :end_time, presence: true
end
