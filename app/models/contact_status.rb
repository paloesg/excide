class ContactStatus < ApplicationRecord
  belongs_to :startup, class_name: "Investment"
  has_many :contacts, dependent: :destroy
end
