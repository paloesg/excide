class ContactStatus < ApplicationRecord
  belongs_to :startup, class_name: "Company"

  has_many :contacts, dependent: :destroy

  acts_as_list scope: :startup
end
