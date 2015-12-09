class Qualification < ActiveRecord::Base
  belongs_to :profile

  validates :title, :institution, :year_obtained, presence: true
end
