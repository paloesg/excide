class XeroTrackingCategory < ApplicationRecord
  belongs_to :company
  validates :name, presence: true
  validates :tracking_category_id, presence: true, uniqueness: true
end