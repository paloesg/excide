class Response < ApplicationRecord
  belongs_to :question
  belongs_to :choice
  belongs_to :segment

  has_one_attached :file
end
