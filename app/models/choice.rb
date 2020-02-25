class Choice < ApplicationRecord
  has_and_belongs_to_many :questions

  has_many :responses
  # accepts_nested_attributes_for :questions
end
