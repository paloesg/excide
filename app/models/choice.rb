class Choice < ActiveRecord::Base
  has_and_belongs_to_many :questions

  has_many :responses
end
