class ContactStatus < ApplicationRecord
  belongs_to :startup, class_name: "Company"

  has_many :contacts, dependent: :destroy
end
