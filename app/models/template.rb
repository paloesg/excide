class Template < ActiveRecord::Base
  has_many :sections
  has_many :surveys

  enum business_model: [:ecommerce, :marketplace, :media, :mobile, :saas, :others]
end
