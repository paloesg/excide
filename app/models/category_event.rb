class CategoryEvent < ApplicationRecord
  belongs_to :categories
  belongs_to :events
end
