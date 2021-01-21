class ContactStatus < ApplicationRecord
  belongs_to :startup, class_name: "Investment"
  has_and_belongs_to_many :contacts
end
