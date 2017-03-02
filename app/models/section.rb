class Section < ActiveRecord::Base
  belongs_to :template

  has_many :questions
  has_many :segments
end
