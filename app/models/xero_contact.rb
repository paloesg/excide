class XeroContact < ApplicationRecord
  belongs_to :company
  validates :name, presence: true
  validates :contact_id, presence: true, uniqueness: true
end
