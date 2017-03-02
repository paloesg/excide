class Template < ActiveRecord::Base
  has_many :sections
  has_many :surveys
end
