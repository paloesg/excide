class Response < ApplicationRecord
  belongs_to :question
  belongs_to :choice
  belongs_to :segment
end
