class Choice < ApplicationRecord
  has_and_belongs_to_many :questions

  has_many :responses
end
