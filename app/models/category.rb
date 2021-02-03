class Category < ApplicationRecord
  belongs_to :department
  has_many :events, through: :categories_events
end
