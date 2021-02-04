class Category < ApplicationRecord
  belongs_to :department
  has_many :event_categories, class_name: 'EventCategory'
  has_many :events, through: :event_categories

  enum category_type: { client: 0, service_line: 1, project: 2, task: 3 }
end
